//
//  PhoneSessionManager.swift
//  Plz
//
//  Created by Ella's Mac on 5/30/25.
//
import Foundation
import WatchConnectivity
import Speech
import BackgroundTasks
import AVFoundation

class PhoneSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneSessionManager()
    
    @Published var startTime: String = ""
    @Published var exitTime: String = ""
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // ✅ PhoneMessageReceiver 인스턴스를 내부에서 직접 생성
    private let messageReceiver = PhoneMessageReceiver()
    
    private override init() {
        super.init()
        setupSpeechRecognition()
        activateSession()
        registerBackgroundTask()
    }
    
    private func setupSpeechRecognition() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("✅ 음성인식 권한 승인됨")
            case .denied, .restricted, .notDetermined:
                print("❌ 음성인식 권한 거부됨")
            @unknown default:
                break
            }
        }
    }
    
    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.audioprocessing", using: nil) { task in
            self.handleBackgroundAudioProcessing(task: task as! BGProcessingTask)
        }
    }
    
    // ✅ 메시지를 받았을 때 messageReceiver로 전달해줘야 시간 데이터 저장됨
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("📨 [Manager] 메시지 수신: \(message)")
        if let audioData = message["audioData"] as? Data,
           message["needsImmediateProcessing"] as? Bool == true {
            print("📥 즉시 처리용 오디오 데이터 수신됨")
            
            processAudioData(audioData) { recognizedText in
                let response = ["recognizedText": recognizedText]
                replyHandler(response)
                print("✅ 즉시 처리 완료: \(recognizedText)")
            }
            return
        }
        
        // ✅ 시간, 제안 메시지 등은 messageReceiver로 전달
        messageReceiver.session(session, didReceiveMessage: message)
        
        // ✅ (선택사항) startTime, exitTime을 UI에서 바로 쓸 수 있도록 별도로 저장
        DispatchQueue.main.async {
            if let startTime = message["startTime"] as? String {
                self.startTime = startTime
                print("✅ 받은 startTime: \(startTime)")
            } else if let exitTime = message["exitTime"] as? String {
                self.exitTime = exitTime
                print("✅ 받은 exitTime: \(exitTime)")
            }
        }
        
        // ✅ replyHandler는 한 번만!
        replyHandler([:])
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📨 [Manager - NoReply] 메시지 수신: \(message)")

        // ✅ 메시지를 messageReceiver로 전달
        messageReceiver.session(session, didReceiveMessage: message)

        // ✅ startTime, exitTime 업데이트
        DispatchQueue.main.async {
            if let startTime = message["startTime"] as? String {
                self.startTime = startTime
                print("✅ 받은 startTime (noReply): \(startTime)")
            } else if let exitTime = message["exitTime"] as? String {
                self.exitTime = exitTime
                print("✅ 받은 exitTime (noReply): \(exitTime)")
            }
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("📥 백그라운드 파일 수신됨: \(file.fileURL.lastPathComponent)")
        
        let sourceURL = file.fileURL
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("receivedAudio_\(UUID().uuidString).m4a")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("📥 오디오 파일 저장 완료: \(destinationURL.lastPathComponent)")
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let audioData = try Data(contentsOf: destinationURL)
                    self.processAudioData(audioData) { recognizedText in
                        DispatchQueue.main.async {
                            self.sendTextToWatch(recognizedText)
                        }
                        try? FileManager.default.removeItem(at: destinationURL)
                    }
                } catch {
                    print("❌ 파일 읽기 실패: \(error)")
                }
            }
            
        } catch {
            print("❌ 파일 저장 실패: \(error.localizedDescription)")
        }
    }
    
    private func handleBackgroundAudioProcessing(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        processPendingAudioFiles { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    private func processAudioData(_ audioData: Data, completion: @escaping (String) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            completion("음성인식을 사용할 수 없습니다")
            return
        }
        
        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio_\(UUID().uuidString).m4a")
            try audioData.write(to: tempURL)
            
            let request = SFSpeechURLRecognitionRequest(url: tempURL)
            request.shouldReportPartialResults = false
            request.requiresOnDeviceRecognition = false
            
            recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                defer {
                    try? FileManager.default.removeItem(at: tempURL)
                }
                
                if let result = result, result.isFinal {
                    completion(result.bestTranscription.formattedString)
                } else if let error = error {
                    print("❌ 음성인식 오류: \(error)")
                    completion("음성인식 실패")
                } else if let result = result {
                    completion(result.bestTranscription.formattedString)
                }
            }
            
        } catch {
            print("❌ 임시 파일 생성 실패: \(error)")
            completion("파일 처리 실패")
        }
    }
    
    func sendTextToWatch(_ text: String) {
        print("📡 Watch 연결 상태: \(WCSession.default.isReachable)")
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["recognizedText": text], replyHandler: nil) { error in
                print("❌ 텍스트 전송 실패: \(error.localizedDescription)")
                self.sendViaContext(text: text)
            }
            print("📤 텍스트 전송 완료: \(text)")
        } else {
            print("⚠️ Watch에 연결되지 않음, Context로 전송합니다")
            sendViaContext(text: text)
        }
    }
    
    private func sendViaContext(text: String) {
        do {
            try WCSession.default.updateApplicationContext(["recognizedText": text])
            print("📤 Context로 전송됨: \(text)")
        } catch {
            print("❌ Context 전송 실패: \(error)")
        }
    }
    
    private func processPendingAudioFiles(completion: @escaping (Bool) -> Void) {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            let audioFiles = files.filter { $0.pathExtension == "m4a" && $0.lastPathComponent.contains("receivedAudio") }
            
            if audioFiles.isEmpty {
                completion(true)
                return
            }
            
            let group = DispatchGroup()
            var allSuccess = true
            
            for audioFile in audioFiles {
                group.enter()
                do {
                    let audioData = try Data(contentsOf: audioFile)
                    processAudioData(audioData) { recognizedText in
                        self.sendTextToWatch(recognizedText)
                        try? FileManager.default.removeItem(at: audioFile)
                        group.leave()
                    }
                } catch {
                    print("❌ 백그라운드 파일 처리 실패: \(error)")
                    allSuccess = false
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(allSuccess)
            }
            
        } catch {
            print("❌ 임시 디렉토리 확인 실패: \(error)")
            completion(false)
        }
    }
    
    // ✅ 필요 시 외부에서 messageReceiver에 접근할 수 있도록 getter 제공
    var messageReceiverInstance: PhoneMessageReceiver {
        return messageReceiver
    }
    
    func recognizeSpeech(from url: URL) {
        do {
            let audioData = try Data(contentsOf: url)
            processAudioData(audioData) { recognizedText in
                self.sendTextToWatch(recognizedText)
            }
        } catch {
            print("❌ 파일 읽기 실패: \(error)")
        }
    }
    
    
    // MARK: - 필수 WCSessionDelegate 구현
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("✅ WCSession 활성화 완료. 상태: \(activationState.rawValue), 에러: \(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("ℹ️ 세션 비활성화됨")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("ℹ️ 세션 비활성화 해제됨 → 새로운 세션으로 활성화 가능")
    }
}
