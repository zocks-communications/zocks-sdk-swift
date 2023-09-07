import SwiftUI
import LiveKit
import WebRTC
import Combine

extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func notify() {
        DispatchQueue.main.async { self.objectWillChange.send() }
    }
}

// This class contains the logic to control behavior of the whole app.
final class AppContext: ObservableObject {

    @Published var outputDevice: RTCAudioDevice = RTCAudioDevice.defaultDevice(with: .output) {
        didSet {
            print("didSet outputDevice: \(String(describing: outputDevice))")

            if !Room.audioDeviceModule.setOutputDevice(outputDevice) {
                print("failed to set value")
            }
        }
    }

    @Published var inputDevice: RTCAudioDevice = RTCAudioDevice.defaultDevice(with: .input) {
        didSet {
            print("didSet inputDevice: \(String(describing: inputDevice))")

            if !Room.audioDeviceModule.setInputDevice(inputDevice) {
                print("failed to set value")
            }
        }
    }

    @Published var preferSpeakerOutput: Bool = true {
        didSet { AudioManager.shared.preferSpeakerOutput = preferSpeakerOutput }
    }

    public init() {
        Room.audioDeviceModule.setDevicesUpdatedHandler {
            print("devices did update")
            // force UI update for outputDevice / inputDevice
            DispatchQueue.main.async {

                // set to default device if selected device is removed
                if !Room.audioDeviceModule.outputDevices.contains(where: { self.outputDevice == $0 }) {
                    self.outputDevice = RTCAudioDevice.defaultDevice(with: .output)
                }

                // set to default device if selected device is removed
                if !Room.audioDeviceModule.inputDevices.contains(where: { self.inputDevice == $0 }) {
                    self.inputDevice = RTCAudioDevice.defaultDevice(with: .input)
                }

                self.objectWillChange.send()
            }
        }
    }
}
