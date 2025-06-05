//
//  PhoneMessageReceiver.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import Foundation
import WatchConnectivity

class PhoneMessageReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedSuggestions: [WordSuggestion] = []

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // ✅ 메시지 수신
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let data = message["suggestions"] as? Data,
           let decoded = try? JSONDecoder().decode([WordSuggestion].self, from: data) {
            DispatchQueue.main.async {
                self.receivedSuggestions = decoded
                print("📥 수신 완료: \(decoded)")
            }
        }
    }

    // ✅ iOS에서는 사실 필수는 아님. 로그만 적당히 넣자.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("✅ iOS session activation complete. State: \(activationState.rawValue), Error: \(String(describing: error))")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("ℹ️ sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("ℹ️ sessionDidDeactivate")
    }
}
