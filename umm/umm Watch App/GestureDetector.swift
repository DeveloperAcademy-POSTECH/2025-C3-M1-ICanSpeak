import WatchKit
import Foundation
import CoreMotion

class GestureDetector: ObservableObject {
    private let motionManager = CMMotionManager()

    func startDetecting() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion else { return }

                let pitch = motion.attitude.pitch
                if pitch > 1.0 {
                    WKInterfaceDevice.current().play(.notification)
                    NotificationCenter.default.post(name: NSNotification.Name("WristRaised"), object: nil)
                }
            }
        }
    }

    func stopDetecting() {
        motionManager.stopDeviceMotionUpdates()
    }
}
