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
    
    // 백그라운드 작업 등록
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.audioprocessing", using: nil) { task in
            self.handleBackgroundAudioProcessing(task: task as! BGProcessingTask)
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
    
    // ✅ 즉시 처리용 메시지 수신 (아이폰 포그라운드일 때)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        // 오디오 데이터 즉시 처리
        if let audioData = message["audioData"] as? Data,
           message["needsImmediateProcessing"] as? Bool == true {
            
            print("📥 즉시 처리용 오디오 데이터 수신됨")
            
            processAudioData(audioData) { [weak self] recognizedText in
                let response = ["recognizedText": recognizedText]
                replyHandler(response)
                print("✅ 즉시 처리 완료: \(recognizedText)")
            }
            return
        }
        
        // 기존 시간 메시지 처리
        DispatchQueue.main.async {
            if let startTime = message["startTime"] as? String {
                self.startTime = startTime
                print("✅ 받은 startTime: \(startTime)")
            } else if let exitTime = message["exitTime"] as? String {
                self.exitTime = exitTime
                print("✅ 받은 exitTime: \(exitTime)")
            }
        }
        
        replyHandler([:])
    }
    
    // ✅ 백그라운드 파일 수신 처리 (아이폰 백그라운드일 때)
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("📥 백그라운드 파일 수신됨: \(file.fileURL.lastPathComponent)")
        
        let sourceURL = file.fileURL
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("receivedAudio_\(UUID().uuidString).m4a")
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("📥 오디오 파일 저장 완료: \(destinationURL.lastPathComponent)")
            
            // 백그라운드에서도 처리 가능하도록
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let audioData = try Data(contentsOf: destinationURL)
                    self.processAudioData(audioData) { recognizedText in
                        DispatchQueue.main.async {
                            self.sendTextToWatch(recognizedText)
                        }
                        
                        // 임시 파일 삭제
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
    
    // 백그라운드 작업 처리
    private func handleBackgroundAudioProcessing(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // 대기 중인 오디오 파일들 처리
        processPendingAudioFiles { success in
            task.setTaskCompleted(success: success)
        }
    }
    
    // ✅ 핵심 음성 인식 처리 로직 (백그라운드에서도 작동)
    private func processAudioData(_ audioData: Data, completion: @escaping (String) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            completion("음성인식을 사용할 수 없습니다")
            return
        }
        
        do {
            // 임시 파일 생성
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio_\(UUID().uuidString).m4a")
            try audioData.write(to: tempURL)
            
            let request = SFSpeechURLRecognitionRequest(url: tempURL)
            request.shouldReportPartialResults = false
            request.requiresOnDeviceRecognition = false // 온라인 인식 사용 (더 정확함)
            
            recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                defer {
                    // 임시 파일 삭제
                    try? FileManager.default.removeItem(at: tempURL)
                }
                
                if let result = result, result.isFinal {
                    let recognizedText = result.bestTranscription.formattedString
                    completion(recognizedText)
                } else if let error = error {
                    print("❌ 음성인식 오류: \(error)")
                    completion("음성인식 실패")
                } else if let result = result {
                    // 최종 결과가 아직 안 왔지만 일단 현재 결과 사용
                    let recognizedText = result.bestTranscription.formattedString
                    completion(recognizedText)
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
                // 실패하면 context로 재시도
                self.sendViaContext(text: text)
            }
            print("📤 텍스트 전송 완료: \(text)")
        } else {
            print("⚠️ Watch에 연결되지 않았습니다. Context로 전송합니다.")
            sendViaContext(text: text)
        }
    }
    
    // Context로 전송 (연결이 끊어져도 나중에 전달됨)
    private func sendViaContext(text: String) {
        do {
            let context = ["recognizedText": text]
            try WCSession.default.updateApplicationContext(context)
            print("📤 Context로 결과 전송됨: \(text)")
        } catch {
            print("❌ Context 전송 실패: \(error)")
        }
    }
    
    // 대기 중인 파일들 처리 (백그라운드용)
    private func processPendingAudioFiles(completion: @escaping (Bool) -> Void) {
        // 임시 디렉토리에서 처리되지 않은 오디오 파일들 찾기
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
    
    // ✅ 기존 메서드들 (호환성 유지)
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
}
