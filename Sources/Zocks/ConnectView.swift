import Foundation
import SwiftUI
import LiveKit

struct ConnectView: View {

    @EnvironmentObject var roomCtx: RoomContext

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 40.0) {
                    if case .connecting = roomCtx.connectionState {
                        ProgressView()
                    } else {
                        HStack(alignment: .center) {
                            Spacer()

                            ZButton(title: "Connect") {
                                Task {
                                    try await roomCtx.connect()
                                    return
                                }
                            }.frame(maxWidth: 170)
                            Spacer()
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)      // Make the scroll view full-width
                .frame(minHeight: geometry.size.height) // Set the content’s min height to the parent
            }
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 500)
        #endif
        .alert(isPresented: $roomCtx.shouldShowError) {
            Alert(title: ZText("Error"),
                  message: ZText(roomCtx.latestError != nil
                                    ? String(describing: roomCtx.latestError!)
                                    : "Unknown error"))
        }
    }
}
