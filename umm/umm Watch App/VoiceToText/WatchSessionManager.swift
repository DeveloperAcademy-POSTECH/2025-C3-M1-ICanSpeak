//
//  WatchSessionManager.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/30/25.
//
import WatchConnectivity
import Foundation


class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    
    @Published var receivedText: String = "원하는 단어를\n말해보세요." // ✅ 텍스트 저장용 변수 추가

    
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
    
    func sendAudioFile(url: URL) {
        if WCSession.default.isReachable {
            WCSession.default.transferFile(url, metadata: nil)
            print("📤 오디오 파일 전송 시작: \(url.lastPathComponent)")
        } else {
            print("⚠️ iPhone에 연결되어 있지 않음")
        }
    }
    
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
    
    // 필수 delegate - 구현만 해놓자
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ Watch 세션 활성화 완료: \(activationState.rawValue)")
    }
  
  
  func sendStartTimeToApp(date: Date) {
    let formatter = ISO8601DateFormatter()
    let dateString = formatter.string(from: date)
    let message = ["startTime": dateString]
    
    if WCSession.default.isReachable {
      WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
        print("❌ 오류 발생: \(error.localizedDescription)")
      })
      print("📤 시작 시간 전송됨: \(dateString)")
    } else {
      print("⚠️ iPhone에 연결되어 있지 않음")
    }
  }

  func sendExitTimeToApp(date: Date) {
      let formatter = ISO8601DateFormatter()
      let dateString = formatter.string(from: date)
      let message = ["exitTime": dateString]

      if WCSession.default.isReachable {
          WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
              print("❌ 오류 발생: \(error.localizedDescription)")
          })
          print("📤 종료 시간 전송됨: \(dateString)")
      } else {
          print("⚠️ iPhone에 연결되어 있지 않음")
      }
  }
  
}

