//
//  PhoneSessionManager.swift
//  Plz
//
//  Created by Ella's Mac on 5/30/25.
//

import Foundation
import WatchConnectivity
import Speech

class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            print("✅ WCSession 활성화 완료. 상태: \(activationState.rawValue)")
        }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
           print("🔄 세션 비활성화됨")
       }
    
    func sessionDidDeactivate(_ session: WCSession) {
          print("🛑 세션 종료됨. 새로운 세션 활성화 가능")
          WCSession.default.activate()
      }

    // 파일 수신 처리
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        let sourceURL = file.fileURL
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("receivedAudio.m4a")
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("📥 오디오 파일 저장 완료: \(destinationURL.lastPathComponent)")
            
            // 👉 음성 인식 함수 호출
            recognizeSpeech(from: destinationURL)
            
        } catch {
            print("❌ 파일 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func sendTextToWatch(_ text: String) {
        print("📡 Watch 연결 상태: \(WCSession.default.isReachable)")

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["recognizedText": text], replyHandler: nil) { error in
                print("❌ 텍스트 전송 실패: \(error.localizedDescription)")
            }
            print("📤 텍스트 전송 완료: \(text)")
        } else {
            print("⚠️ Watch에 연결되지 않았습니다.")
        }
    }
    
//    func sendTextToWatch(_ text: String) {
//        if WCSession.default.isReachable {
//            WCSession.default.sendMessage(["recognizedText": text], replyHandler: nil) { error in
//                print("❌ 텍스트 전송 실패: \(error.localizedDescription)")
//            }
//            print("📤 텍스트 전송 완료: \(text)")
//        } else {
//            print("⚠️ Watch에 연결되지 않았습니다.")
//        }
//    }
}

func recognizeSpeech(from url: URL) {
    SFSpeechRecognizer.requestAuthorization { authStatus in
        guard authStatus == .authorized else {
            print("❌ 음성 인식 권한이 없습니다")
            return
        }

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = false

        recognizer?.recognitionTask(with: request) { result, error in
            if let error = error {
                print("❌ 인식 오류: \(error.localizedDescription)")
                return
            }

            guard let result = result else {
                print("⚠️ 인식 결과 없음")
                return
            }

            if result.isFinal {
                // ⚠️ 여기에 나중에 Watch로 결과 보내는 코드 넣을 예정
                let finalText = result.bestTranscription.formattedString
                print("📝 인식된 텍스트: \(result.bestTranscription.formattedString)")
                PhoneSessionManager.shared.sendTextToWatch(finalText)
            }
        }
    }
}
