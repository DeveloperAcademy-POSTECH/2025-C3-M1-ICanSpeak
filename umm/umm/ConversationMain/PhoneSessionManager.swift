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
    @Published var receivedSuggestions: [WordSuggestion] = []
    @Published var conversationSessions: [ConversationSession] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // 현재 진행 중인 세션
    private var currentSession: ConversationSession?
    
    private override init() {
        super.init()
        setupSpeechRecognition()
        activateSession()
        registerBackgroundTask()
        loadSavedSessions()
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
            session.delegate = self  // ✅ 하나의 delegate로 통합
            session.activate()
        }
    }
    
    // 백그라운드 작업 등록
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.audioprocessing", using: nil) { task in
            self.handleBackgroundAudioProcessing(task: task as! BGProcessingTask)
        }
    }
    
    // MARK: - WCSessionDelegate 구현
    
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
    
    // ✅ 통합된 메시지 수신 처리 (Reply Handler 있는 버전)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("📨 [Manager] 메시지 수신: \(message)")
        
        // 오디오 데이터 즉시 처리
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
        
        // 시간 및 제안 메시지 처리
        DispatchQueue.main.async {
            // 시작 시간 처리
            if let startTimeString = message["startTime"] as? String {
                self.startTime = startTimeString
                self.handleStartTime(startTimeString)
                print("✅ 받은 startTime: \(startTimeString)")
            }
            
            // 종료 시간 처리
            if let exitTimeString = message["exitTime"] as? String {
                self.exitTime = exitTimeString
                self.handleExitTime(exitTimeString)
                print("✅ 받은 exitTime: \(exitTimeString)")
            }
            
            // WordSuggestion 배열 처리
            if let data = message["suggestions"] as? Data,
               let decoded = try? JSONDecoder().decode([WordSuggestion].self, from: data) {
                let keyword = message["keyword"] as? String
                self.handleReceivedSuggestions(decoded, keyword: keyword ?? "알 수 없음")
            }
        }
        
        replyHandler([:])
    }
    
    // ✅ 통합된 메시지 수신 처리 (Reply Handler 없는 버전)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📨 [Manager - NoReply] 메시지 수신: \(message)")

        DispatchQueue.main.async {
            // 시작 시간 처리
            if let startTimeString = message["startTime"] as? String {
                self.startTime = startTimeString
                self.handleStartTime(startTimeString)
                print("✅ 받은 startTime (noReply): \(startTimeString)")
            }
            
            // 종료 시간 처리
            if let exitTimeString = message["exitTime"] as? String {
                self.exitTime = exitTimeString
                self.handleExitTime(exitTimeString)
                print("✅ 받은 exitTime (noReply): \(exitTimeString)")
            }
            
            // WordSuggestion 배열 처리
            if let data = message["suggestions"] as? Data,
               let decoded = try? JSONDecoder().decode([WordSuggestion].self, from: data) {
                let keyword = message["keyword"] as? String
                self.handleReceivedSuggestions(decoded, keyword: keyword ?? "알 수 없음")
            }
        }
    }
    
    // ✅ 백그라운드 파일 수신 처리
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
    
    // MARK: - 대화 세션 관리 (기존 PhoneMessageReceiver 기능 통합)
    
    // 시작 시간 처리 - 새로운 ConversationSession 시작
    private func handleStartTime(_ startTimeString: String) {
        let formatter = ISO8601DateFormatter()
        guard let startTime = formatter.date(from: startTimeString) else {
            print("❌ 시작 시간 파싱 실패: \(startTimeString)")
            return
        }
        
        // 새로운 세션 시작
        currentSession = ConversationSession(
            startTime: startTime,
            endTime: nil,
            groups: []
        )
        
        print("✅ 새로운 대화 세션 시작: \(startTime)")
    }
    
    // 종료 시간 처리 - 현재 세션 완료
    private func handleExitTime(_ exitTimeString: String) {
        let formatter = ISO8601DateFormatter()
        guard let exitTime = formatter.date(from: exitTimeString),
              var session = currentSession else {
            print("❌ 종료 시간 처리 실패")
            return
        }
        
        // 현재 세션에 종료 시간 설정
        session.endTime = exitTime
        
        // 완료된 세션을 배열에 추가 (최신순으로 정렬)
        conversationSessions.insert(session, at: 0)
        
        // 현재 세션 초기화
        currentSession = nil
        
        // 저장
        saveSessions()
        
        print("✅ 대화 세션 완료: \(session.startTime) ~ \(exitTime)")
        print("총 그룹 수: \(session.groups.count)")
    }
    
    // WordSuggestion 배열을 받아서 현재 세션에 그룹으로 추가
    private func handleReceivedSuggestions(_ suggestions: [WordSuggestion], keyword: String) {
        guard !suggestions.isEmpty else { return }
        
        // 현재 세션이 없으면 임시로 생성 (혹시 시작 메시지를 놓친 경우)
        if currentSession == nil {
            currentSession = ConversationSession(
                startTime: Date(),
                endTime: nil,
                groups: []
            )
            print("⚠️ 시작 메시지 없이 제안 수신, 임시 세션 생성")
        }
        
        let newGroup = WordSuggestionGroup(
            keyword: keyword,
            suggestions: suggestions
        )
        
        currentSession?.groups.append(newGroup)
        
        // UI 업데이트용
        receivedSuggestions = suggestions
        
        print("📥 그룹 추가됨 - 키워드: \(keyword), 제안 수: \(suggestions.count)")
    }
    
    // MARK: - 세션 데이터 관리
    
    // 세션 저장
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(conversationSessions) {
            UserDefaults.standard.set(encoded, forKey: "ConversationSessions")
        }
    }
    
    // 저장된 세션 불러오기
    private func loadSavedSessions() {
        if let data = UserDefaults.standard.data(forKey: "ConversationSessions"),
           let decoded = try? JSONDecoder().decode([ConversationSession].self, from: data) {
            conversationSessions = decoded
        }
    }
    
    // 세션 삭제
    func deleteSession(at indexSet: IndexSet) {
        conversationSessions.remove(atOffsets: indexSet)
        saveSessions()
    }
    
  func deleteGroup(withId groupId: UUID) {
    for index in conversationSessions.indices {
      if let groupIndex = conversationSessions[index].groups.firstIndex(where: { $0.id == groupId }) {
        conversationSessions[index].groups.remove(at: groupIndex)
        // 세션이 비어 있으면 제거
        if conversationSessions[index].groups.isEmpty {
          conversationSessions.remove(at: index)}
        saveSessions()
        break
      }
    }
  }
  
    // MARK: - 음성 인식 처리
    
    // ✅ 핵심 음성 인식 처리 로직
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

            var hasCompleted = false // ✅ 중복 호출 방지

            recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                defer {
                    try? FileManager.default.removeItem(at: tempURL)
                }

                guard !hasCompleted else { return }

                if let result = result, result.isFinal {
                    hasCompleted = true
                    completion(result.bestTranscription.formattedString)
                } else if let error = error {
                    hasCompleted = true
                    print("❌ 음성인식 오류: \(error)")
                    completion("음성인식 실패")
                } else if let result = result {
                    hasCompleted = true
                    completion(result.bestTranscription.formattedString)
                }
            }

        } catch {
            print("❌ 임시 파일 생성 실패: \(error)")
            completion("파일 처리 실패")
        }
    }
    
    // MARK: - Watch 통신
    
    func sendTextToWatch(_ text: String) {
        print("📡 Watch 연결 상태: \(WCSession.default.isReachable)")

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["recognizedText": text], replyHandler: nil) { error in
                print("❌ 텍스트 전송 실패: \(error.localizedDescription)")
                self.sendViaContext(text: text)
            }
            print("📤 텍스트 전송 완료: \(text)")
        } else {
            print("⚠️ Watch에 연결되지 않았습니다. Context로 전송합니다.")
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
    
    // MARK: - 백그라운드 처리
    
    private func handleBackgroundAudioProcessing(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        processPendingAudioFiles { success in
            task.setTaskCompleted(success: success)
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
    
    // MARK: - 기존 호환성 메서드
    
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
