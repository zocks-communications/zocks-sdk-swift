import SwiftUI
import LiveKit
import WebRTC
import Promises

// This class contains the logic to control behavior of the whole app.
final class RoomContext: ObservableObject {

    let id: String?
    let name: String?
    let autoCreate: Bool
    let client: MediaClient
    
    init(configuration: Configuration, id: String? = nil, name: String? = nil, autoCreate: Bool = false) {
        self.id = id
        self.name = name
        self.autoCreate = autoCreate
        self.client = MediaClient(configuration: configuration)
    }
    
    // Used to show connection error dialog
    // private var didClose: Bool = false
    @Published
    var shouldShowError: Bool = false

    @Published
    var connectionState: ConnectionState = .disconnected()

    public var latestError: Error?

    public let room = ZocksObservableRoom()

    @discardableResult
    func connect() async throws -> Room {
        DispatchQueue.main.async {
            self.connectionState = .connecting
        }
        let response = try await client.joinRoom(roomId: id, roomName: name, autoCreate: autoCreate)
        let connectOptions = ConnectOptions(
            autoSubscribe: true,
            rtcConfiguration: response.joinInfo.toRTCConfiguration()
        )

        let roomOptions = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
                dimensions: .h1080_169
            ),
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                dimensions: .h1080_169,
                useBroadcastExtension: true
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: true
            ),
            adaptiveStream: true,
            dynacast: true,
            reportStats: false
        )
        defer {
            Task { @MainActor in
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
        let room = try await room.room.connect(response.joinInfo.webSocketUrl,
                                           response.joinInfo.token,
                                           connectOptions: connectOptions,
                                           roomOptions: roomOptions)
        DispatchQueue.main.async {
            self.connectionState = .connected
        }
        return room
    }

    func disconnect() {
        defer {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        room.room.disconnect().then({
            DispatchQueue.main.async {
                self.connectionState = .disconnected()
            }
        })
    }
}

extension JoinInfo {
    func toRTCConfiguration() -> RTCConfiguration {
        let rtcConfiguration = RTCConfiguration()
        rtcConfiguration.iceServers = turnServers.map({ t in
            RTCIceServer(urlStrings: t.urls, username: t.username, credential: t.password)
        })
        rtcConfiguration.iceTransportPolicy = forceEdge ? .relay : .all
        return rtcConfiguration
    }
}

extension RoomContext: RoomDelegate {

    func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        print("Did update connectionState \(oldValue) -> \(connectionState)")

        if let error = connectionState.disconnectedWithNetworkError {
            latestError = error
            DispatchQueue.main.async {
                self.shouldShowError = true
            }
        }

        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
}
