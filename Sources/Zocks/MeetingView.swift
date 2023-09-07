import SwiftUI
import Logging
import LiveKit

public struct MeetingView: View {

    @StateObject var appCtx = AppContext()
    @StateObject var roomCtx: RoomContext

    public init(configuration: Configuration, id: String? = nil, name: String? = nil, autoCreate: Bool = false) {
        _roomCtx = StateObject(wrappedValue: RoomContext(configuration: configuration, id: id, name: name, autoCreate: autoCreate))
    }

    var shouldShowRoomView: Bool {
        roomCtx.room.room.connectionState.isConnected || roomCtx.room.room.connectionState.isReconnecting
    }

    func computeTitle() -> String {
        if shouldShowRoomView {
            let elements = [roomCtx.room.room.name,
                            roomCtx.room.room.localParticipant?.name,
                            roomCtx.room.room.localParticipant?.identity]
            return elements.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        }

        return "Zocks"
    }

    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if shouldShowRoomView {
                RoomView()
            } else {
                ConnectView()
            }

        }
        .environment(\.colorScheme, .dark)
        .foregroundColor(Color.white)
        .environmentObject(appCtx)
        .environmentObject(roomCtx)
        .environmentObject(roomCtx.room)
        .navigationTitle(computeTitle())
        .onDisappear {
            print("\(String(describing: type(of: self))) onDisappear")
            roomCtx.disconnect()
        }
        .modifier(HandleErrorsByShowingAlertViewModifier())
    }
}


#if os(macOS)

extension View {
    func withHostingWindow(_ callback: @escaping (NSWindow) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

struct HostingWindowFinder: NSViewRepresentable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            if let window = view?.window {
                self.callback(window)
            }
        }
        return view
    }

    func updateNSView(_ uiView: NSView, context: Context) {}
}
#endif
