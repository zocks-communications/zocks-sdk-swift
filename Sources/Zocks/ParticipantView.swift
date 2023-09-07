import SwiftUI
import LiveKit

extension Participant {
    var initial: String {
        get {
            name.count > 0 ? name.prefix(1).uppercased() : "?"
        }
    }
}

struct ParticipantView: View {

    @ObservedObject var participant: ObservableParticipant
    @EnvironmentObject var appCtx: AppContext

    var videoViewMode: VideoView.LayoutMode = .fill
    var onTap: ((_ participant: ObservableParticipant) -> Void)?

    @State private var isRendering: Bool = false
    @State private var dimensions: Dimensions?
    @State private var trackStats: TrackStats?

    func bgView(geometry: GeometryProxy) -> some View {
        ZText(participant.participant.initial, size: 32.0)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: min(geometry.size.width, geometry.size.height) * 0.3)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
    }
        
    private func isMicrophoneMuted() -> Bool {
        let publication = participant.firstAudioPublication
        return publication == nil || publication!.muted
    }
    
    private func displayName() -> String {
        return participant.participant is LocalParticipant ? "YOU" : participant.participant.name.uppercased()
    }

    var body: some View {
        GeometryReader { geometry in

            ZStack(alignment: .bottom) {
                // Background color
                (
                    participant.isSpeaking ? Color.purple5 : Color.grey3
                )
                    .ignoresSafeArea()

                let track = participant.mainVideoTrack
                // VideoView for the Participant
                if track != nil {
                    ZStack(alignment: .topLeading) {
                        SwiftUIVideoView(track!,
                                         layoutMode: videoViewMode,
                                         mirrorMode: participant.participant is LocalParticipant ? .mirror : .auto,
                                         debugMode: false,
                                         isRendering: $isRendering,
                                         dimensions: $dimensions,
                                         trackStats: $trackStats)

                        if !isRendering {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                                // .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                    }
                } else {
                    // Show no camera icon
                    bgView(geometry: geometry)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        ZText(displayName(), size: 12)
                            .padding(.leading, 16)
                            .padding(.top, 20)
                        Spacer()
                    }
                    Spacer()
                    // Bottom user info bar
                    HStack {
                        if isMicrophoneMuted() {
                            if track != nil {
                                Icon(icon: .micOff, color: .white)
                                    .padding(5)
                                    .background(
                                        Circle().fill(Color.transparentGrey40), alignment: .center
                                    )
                                    .padding(.leading, 12)
                                    .padding(.bottom, 12)
                            } else {
                                Icon(icon: .micOff, color: .transparentWhite40)
                                    .padding(.leading, 12)
                                    .padding(.bottom, 12)
                            }
                        }
                        Spacer()
                        if track != nil {
                            Icon(icon: participant.isSpeaking ? .soundWaveOn : .soundWaveOff, color: .white)
                                .padding(5)
                                .background(
                                    Circle().fill(Color.transparentGrey40), alignment: .center
                                )
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        } else {
                            Icon(icon: participant.isSpeaking ? .soundWaveOn : .soundWaveOff, color: .white)
                                .padding(.trailing, 8)
                                .padding(.bottom, 8)
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
            // Glow the border when the participant is speaking
            .overlay(
                participant.isSpeaking ?
                    Rectangle()
                    .stroke(Color.purple5, lineWidth: 3.0)
                    : nil
            )
        }.gesture(TapGesture()
                    .onEnded { _ in
                        // Pass the tap event
                        onTap?(participant)
                    })
    }
}
