//
//  WatchSessionManager.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/30/25.
//
//import WatchConnectivity
//import Foundation
//
//class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
//    static let shared = WatchSessionManager()
//    
//    @Published var receivedText: String = "원하는 단어를\n말해보세요."
//    
//    private override init() {
//        super.init()
//        activateSession()
//    }
//    
//    private func activateSession() {
//        if WCSession.isSupported() {
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//            print("✅ WatchConnectivity 세션 활성화됨")
//        }
//    }
//    
//    // ✅ 개선된 오디오 전송 방법
//    func sendAudioFile(url: URL) {
//        // 1단계: 즉시 메시지로 전송 시도 (아이폰이 포그라운드일 때)
//        if WCSession.default.isReachable {
//            sendAudioAsMessage(url: url)
//        } else {
//            // 2단계: 파일 전송으로 백업 (백그라운드 처리용)
//            sendAudioAsFile(url: url)
//        }
//    }
//    
//    // 즉시 처리용 - 오디오를 Data로 변환해서 메시지로 전송
//    private func sendAudioAsMessage(url: URL) {
//        do {
//            
//            let audioData = try Data(contentsOf: url)
//            let message: [String: Any] = [
//                "audioData": audioData,
//                "timestamp": Date().timeIntervalSince1970,
//                "needsImmediateProcessing": true
//            ]
//            
//            WCSession.default.sendMessage(message, replyHandler: { response in
//                print("✅ 즉시 처리 완료")
//                if let recognizedText = response["recognizedText"] as? String {
//                    DispatchQueue.main.async {
//                        self.receivedText = recognizedText
//                    }
//                }
//            }, errorHandler: { error in
//                print("⚠️ 즉시 처리 실패, 파일 전송으로 전환: \(error)")
//                self.sendAudioAsFile(url: url)
//            })
//            
//            print("📤 오디오 메시지 전송 시작: \(url.lastPathComponent)")
//            
//        } catch {
//            print("❌ 오디오 파일 읽기 실패: \(error)")
//            sendAudioAsFile(url: url)
//        }
//    }
//    
//    // 백그라운드 처리용 - 파일 전송
//    private func sendAudioAsFile(url: URL) {
//        let metadata = [
//            "timestamp": "\(Date().timeIntervalSince1970)",
//            "needsBackgroundProcessing": "true"
//        ]
//        
//        WCSession.default.transferFile(url, metadata: metadata)
//        print("📤 오디오 파일 전송 시작 (백그라운드 처리용): \(url.lastPathComponent)")
//    }
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        DispatchQueue.main.async {
//            if let text = message["recognizedText"] as? String {
//                print("📩 받은 텍스트: \(text)")
//                self.receivedText = text
//            } else {
//                print("⚠️ 인식된 텍스트가 없음")
//            }
//        }
//    }
//    
//    // 필수 delegate
//    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        print("✅ Watch 세션 활성화 완료: \(activationState.rawValue)")
//    }
//    
//    func sendStartTimeToApp(date: Date) {
//        let formatter = ISO8601DateFormatter()
//        let dateString = formatter.string(from: date)
//        let message = ["startTime": dateString]
//        
//        if WCSession.default.isReachable {
//            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
//                print("❌ 오류 발생: \(error.localizedDescription)")
//            })
//            print("📤 시작 시간 전송됨: \(dateString)")
//        } else {
//            print("⚠️ iPhone에 연결되어 있지 않음")
//        }
//    }
//    
//    func sendExitTimeToApp(date: Date) {
//        let formatter = ISO8601DateFormatter()
//        let dateString = formatter.string(from: date)
//        let message = ["exitTime": dateString]
//        
//        if WCSession.default.isReachable {
//            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
//                print("❌ 오류 발생: \(error.localizedDescription)")
//            })
//            print("📤 종료 시간 전송됨: \(dateString)")
//        } else {
//            print("⚠️ iPhone에 연결되어 있지 않음")
//        }
//    }
//}

import WatchConnectivity
import Foundation

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published var receivedText: String = "원하는 단어를\n말해보세요."
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("✅ WatchConnectivity 세션 활성화됨")
        }
    }
    
    // ✅ 항상 파일 전송만 사용하는 버전
    func sendAudioFile(url: URL) {
        sendAudioAsFile(url: url)
    }

    // 📤 백그라운드 처리용 - 파일 전송
    private func sendAudioAsFile(url: URL) {
        let metadata = [
            "timestamp": "\(Date().timeIntervalSince1970)",
            "needsBackgroundProcessing": "true"
        ]
        
        WCSession.default.transferFile(url, metadata: metadata)
        print("📤 오디오 파일 전송 시작 (백그라운드 처리용): \(url.lastPathComponent)")
    }
    
    // iPhone에서 텍스트 전송 시 수신 처리
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["recognizedText"] as? String {
                print("📩 받은 텍스트: \(text)")
                self.receivedText = text
            } else {
                print("⚠️ 인식된 텍스트가 없음")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ Watch 세션 활성화 완료: \(activationState.rawValue)")
    }
    
    // 시작 시간 전송
    func sendStartTimeToApp(date: Date) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        let message = ["startTime": dateString]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("❌ 시작 시간 전송 실패: \(error.localizedDescription)")
            })
            print("📤 시작 시간 전송됨: \(dateString)")
        } else {
            print("⚠️ iPhone에 연결되어 있지 않음")
        }
    }
    
    // 종료 시간 전송
    func sendExitTimeToApp(date: Date) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        let message = ["exitTime": dateString]
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("❌ 종료 시간 전송 실패: \(error.localizedDescription)")
            })
            print("📤 종료 시간 전송됨: \(dateString)")
        } else {
            print("⚠️ iPhone에 연결되어 있지 않음")
        }
    }
}
