import SwiftUI
import LiveKit
import WebRTC

#if !os(macOS)
let adaptiveMin = 170.0
let toolbarPlacement: ToolbarItemPlacement = .bottomBar
#else
let adaptiveMin = 300.0
let toolbarPlacement: ToolbarItemPlacement = .primaryAction
#endif

extension CIImage {
    // helper to create a `CIImage` for both platforms
    convenience init(named name: String) {
        #if !os(macOS)
        self.init(cgImage: UIImage(named: name)!.cgImage!)
        #else
        self.init(data: NSImage(named: name)!.tiffRepresentation!)!
        #endif
    }
}

extension RTCIODevice: Identifiable {

    public var id: String {
        deviceId
    }
}

struct RoomView: View {

    @EnvironmentObject var appCtx: AppContext
    @EnvironmentObject var roomCtx: RoomContext
    @EnvironmentObject var room: ZocksObservableRoom

    @State private var screenPickerPresented = false
    @State private var confirmDialogPresented = false
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(Color.grey2)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UIToolbar.appearance().backgroundColor = UIColor(Color.grey2)
        UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }

    func content(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {

            if case .connecting = room.room.connectionState {
                ZText("Re-connecting...")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
            }

            HorVStack(axis: geometry.isTall ? .vertical : .horizontal, spacing: 5) {

                Group {
                    ParticipantLayout(room.participants, spacing: 0) { participant in
                        ParticipantView(participant: participant).aspectRatio(1.0, contentMode: .fit)
                    }
                }
            }
        }
        .padding(2)
    }
    
    private var isCameraEnabled: Bool {
        get {
            (room.room.localParticipant?.isCameraEnabled() ?? false)
        }
    }
    
    private var canSwitchCamera: Bool {
        get {
            isCameraEnabled && CameraCapturer.canSwitchPosition()
        }
    }
    
    private func bottomBar() -> some View {
        HStack {
            Spacer()
            
            Group {
                
                // Toggle microphone enabled
                Spacer()
                
                BottomBarButton(action: {
                    room.toggleMicrophoneEnabled()
                },
                                label: {
                    Icon(
                        icon: (room.room.localParticipant?.isMicrophoneEnabled() ?? false) ? .micOn : .micOff,
                        color: room.microphoneTrackState.isBusy ? .disabled : .white
                    )
                },
                                color: (room.room.localParticipant?.isMicrophoneEnabled() ?? false) ? .grey1 : .errorDark
                )
                // disable while publishing/un-publishing
                .disabled(room.microphoneTrackState.isBusy)
                
                Spacer()
                
                BottomBarButton(action: {
                    room.toggleCameraEnabled()
                },
                                label: {
                    Icon(
                        icon: isCameraEnabled ? .cameraOn : .cameraOff,
                        color: room.cameraTrackState.isBusy ? .disabled : .white
                    )
                },
                                color: isCameraEnabled ? .grey1 : .errorDark
                )
                // disable while publishing/un-publishing
                .disabled(room.cameraTrackState.isBusy)
                
                Spacer()
                
                BottomBarButton(action: {
                    room.switchCameraPosition()
                }, label: {
                    Icon(icon: .cameraSwitch, color: canSwitchCamera ? .white : .disabled)
                })
                .disabled(!canSwitchCamera)
                
                Spacer()
                
                BottomBarButton(action: {
                    appCtx.preferSpeakerOutput = !appCtx.preferSpeakerOutput
                }, label: {
                    Icon(icon: appCtx.preferSpeakerOutput ? .audioDeviceSpeaker : .audioDeviceEarpiece)
                })
                
                Spacer()
                //                #if os(iOS)
                //                BottomBarButton(action: {
                //                    room.toggleScreenShareEnablediOS()
                //                },
                //                       label: {
                //                    Icon(icon: .screenShare, color: room.screenShareTrackState.isPublished ? .blue : .white)
                //                })
                //                #elseif os(macOS)
                //                BottomBarButton(action: {
                //                    if room.room.localParticipant?.isScreenShareEnabled() ?? false {
                //                        // turn off screen share
                //                        room.toggleScreenShareEnabledMacOS(screenShareSource: nil)
                //                    } else {
                //                        screenPickerPresented = true
                //                    }
                //                },
                //                       label: {
                //                    Icon(icon: .screenShare, color: room.screenShareTrackState.isPublished ? .blue : .white)
                //                }).popover(isPresented: $screenPickerPresented) {
                //                    ScreenShareSourcePickerView { source in
                //                        room.toggleScreenShareEnabledMacOS(screenShareSource: source)
                //                        screenPickerPresented = false
                //                    }.padding()
                //                }
                //                #endif
                //
                //                Spacer()
            }
            Group {

                BottomBarButton(
                    action: {
                        confirmDialogPresented.toggle()
                    },
                    label: {
                        Icon(icon: .callEnd)
                    },
                    color: Color.error
                )
                
                Spacer()
            }
            Spacer()
        }
        .frame(minHeight: 96, maxHeight: 96)
        .background(Color.grey2)
    }

    var body: some View {
        Color.grey2
       .edgesIgnoringSafeArea(.all)
        VStack(alignment: .center) {
            GeometryReader { geometry in
                content(geometry: geometry)
                    .background(Color.black)
            }
            Spacer(minLength: 0)
            bottomBar()
        }.modifier(ConfirmDialog(isShowing: $confirmDialogPresented, action: { roomCtx.disconnect() }))
    }
}

struct ParticipantLayout<Content: View>: View {

    let views: [AnyView]
    let spacing: CGFloat

    init<Data: RandomAccessCollection>(
        _ data: Data,
        id: KeyPath<Data.Element, Data.Element> = \.self,
        spacing: CGFloat,
        @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.spacing = spacing
        self.views = data.map { AnyView(content($0[keyPath: id])) }
    }

    func computeColumn(with geometry: GeometryProxy) -> (x: Int, y: Int) {
        let sqr = Double(views.count).squareRoot()
        let r: [Int] = [Int(sqr.rounded()), Int(sqr.rounded(.up))]
        let c = geometry.isTall ? r : r.reversed()
        return (x: c[0], y: c[1])
    }

    func grid(axis: Axis, geometry: GeometryProxy) -> some View {
        ScrollView([ axis == .vertical ? .vertical : .horizontal ]) {
            HorVGrid(axis: axis, columns: [GridItem(.flexible())], spacing: spacing) {
                ForEach(0..<views.count, id: \.self) { i in
                    views[i]
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            .padding(axis == .horizontal ? [.leading, .trailing] : [.top, .bottom],
                     max(0, ((axis == .horizontal ? geometry.size.width : geometry.size.height)
                                - ((axis == .horizontal ? geometry.size.height : geometry.size.width) * CGFloat(views.count)) - (spacing * CGFloat(views.count - 1))) / 2))
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if views.isEmpty {
                EmptyView()
            } else if views.count == 1 {
                views[0]
            } else {
                VStack(spacing: 4) {
                    views[0]
                    ScrollView(.horizontal) {
                        HStack(spacing: 4) {
                            ForEach(0...(views.count - 1), id: \.self) { i in
                                views[i]
                                    .frame(maxHeight: 150)
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct HorVStack<Content: View>: View {
    let axis: Axis
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(axis: Axis = .horizontal,
         horizontalAlignment: HorizontalAlignment = .center,
         verticalAlignment: VerticalAlignment = .center,
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {

        self.axis = axis
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if axis == .vertical {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }
        }
    }
}

struct HorVGrid<Content: View>: View {
    let axis: Axis
    let spacing: CGFloat?
    let content: () -> Content
    let columns: [GridItem]

    init(axis: Axis = .horizontal,
         columns: [GridItem],
         spacing: CGFloat? = nil,
         @ViewBuilder content: @escaping () -> Content) {

        self.axis = axis
        self.spacing = spacing
        self.columns = columns
        self.content = content
    }

    var body: some View {
        Group {
            if axis == .vertical {
                LazyVGrid(columns: columns, spacing: spacing, content: content)
            } else {
                LazyHGrid(rows: columns, spacing: spacing, content: content)
            }
        }
    }
}

extension GeometryProxy {

    public var isTall: Bool {
        size.height > size.width
    }

    var isWide: Bool {
        size.width > size.height
    }
}
