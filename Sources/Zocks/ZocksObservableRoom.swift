import SwiftUI
import LiveKit
import AVFoundation
import Promises

import WebRTC
import CoreImage.CIFilterBuiltins
import ReplayKit

extension ObservableParticipant {

    public var mainVideoPublication: TrackPublication? {
        firstScreenSharePublication ?? firstCameraPublication
    }

    public var mainVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack ?? firstCameraVideoTrack
    }

    public var subVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack != nil ? firstCameraVideoTrack : nil
    }
}

class ZocksObservableRoom: ObservableRoom {

    let queue = DispatchQueue(label: "zocks.observableroom")

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    private var _participants: [ObservableParticipant] = []

    public var participants: [ObservableParticipant] {
        sortedParticipants()
    }

    override init(_ room: Room = Room()) {
        super.init(room)
        room.add(delegate: self)
    }
    
    func sortedParticipants() -> [ObservableParticipant] {
        let merged = mergeParticipants(Array(allParticipants.values))
        var sorted = merged.sorted { p1, p2 in
            if p1.firstScreenShareVideoTrack != nil && p2.firstScreenShareVideoTrack == nil { return true }
            if p1.firstScreenShareVideoTrack == nil && p2.firstScreenShareVideoTrack != nil { return false }
            if p1.isSpeaking && p2.isSpeaking {
                return p1.participant.audioLevel > p2.participant.audioLevel
            }
            if p1.isSpeaking { return true }
            return false
        }
        if sorted.count > 1 {
            let localIdx = sorted.firstIndex(where: { $0.participant is LocalParticipant })
            if localIdx != nil {
                let local = sorted.remove(at: localIdx!)
                sorted.insert(local, at: 1)
            }
        }
        _participants = sorted
        return sorted
    }
    
    private func mergeParticipants(_ participants: [ObservableParticipant]) -> [ObservableParticipant] {
        var toUpdate =  self._participants
        toUpdate.removeAll(where: { u in !participants.contains(where: { p in p.identity == u.identity }) })
        let newParticipants = participants.filter { p in !toUpdate.contains(where: { u in u.identity == p.identity } ) }
        toUpdate.append(contentsOf: newParticipants)
        return toUpdate
    }

    #if os(iOS)
    func toggleScreenShareEnablediOS() {
        toggleScreenShareEnabled()
    }
    #elseif os(macOS)
    func toggleScreenShareEnabledMacOS(screenShareSource: MacOSScreenCaptureSource? = nil) {

        guard let localParticipant = room.localParticipant else {
            print("LocalParticipant doesn't exist")
            return
        }

        guard !screenShareTrackState.isBusy else {
            print("screenShareTrackState is .busy")
            return
        }

        if case .published(let track) = screenShareTrackState {

            DispatchQueue.main.async {
                self.screenShareTrackState = .busy(isPublishing: false)
            }

            localParticipant.unpublish(publication: track).then { _ in
                DispatchQueue.main.async {
                    self.screenShareTrackState = .notPublished()
                }
            }
        } else {

            guard let source = screenShareSource else { return }

            print("selected source: \(source)")

            DispatchQueue.main.async {
                self.screenShareTrackState = .busy(isPublishing: true)
            }

            let track = LocalVideoTrack.createMacOSScreenShareTrack(source: source)
            localParticipant.publishVideoTrack(track: track).then { publication in
                DispatchQueue.main.async {
                    self.screenShareTrackState = .published(publication)
                }
            }.catch { error in
                DispatchQueue.main.async {
                    self.screenShareTrackState = .notPublished(error: error)
                }
            }
        }
    }
    #endif

    @discardableResult
    func unpublishAll() -> Promise<Void> {
        Promise(on: queue) { () -> Void in
            guard let localParticipant = self.room.localParticipant else { return }
            try awaitPromise(localParticipant.unpublishAll())
            DispatchQueue.main.async {
                self.cameraTrackState = .notPublished()
                self.microphoneTrackState = .notPublished()
                self.screenShareTrackState = .notPublished()
            }
        }
    }
    
    override func room(_ room: Room, didUpdate speakers: [Participant]) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    override func room(_ room: Room, participant: RemoteParticipant, didPublish publication: RemoteTrackPublication) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    override func room(_ room: Room, participant: RemoteParticipant, didUnpublish publication: RemoteTrackPublication) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    override func room(_ room: Room, participant: RemoteParticipant, didSubscribe publication: RemoteTrackPublication, track: Track) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
}
