//
//  PhoneMessageReceiver.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

//import Foundation
//import WatchConnectivity
//
//class PhoneMessageReceiver: NSObject, ObservableObject, WCSessionDelegate {
//    @Published var receivedSuggestions: [WordSuggestion] = []
//    @Published var conversationSessions: [ConversationSession] = []
//    
//    // 현재 진행 중인 세션
//    private var currentSession: ConversationSession?
//    
//    override init() {
//        super.init()
//        if WCSession.isSupported() {
////            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
//        loadSavedSessions()
//    }
//
//    // ✅ 메시지 수신 - 시작/종료 시간과 단어 제안을 모두 처리
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("📨 [Receiver] 메시지 수신: \(message)")
//        
//        DispatchQueue.main.async {
//            // 시작 시간 처리
//            if let startTimeString = message["startTime"] as? String {
//                print("✅ [Receiver] startTime 처리 시작")
//                self.handleStartTime(startTimeString)
//            }
//            
//            // 종료 시간 처리
//            if let exitTimeString = message["exitTime"] as? String {
//                print("✅ [Receiver] exitTime 처리 시작")
//                self.handleExitTime(exitTimeString)
//            }
//            
//            // WordSuggestion 배열 처리
//            if let data = message["suggestions"] as? Data,
//               let decoded = try? JSONDecoder().decode([WordSuggestion].self, from: data) {
//                self.handleReceivedSuggestions(decoded)
//            }
//        }
//    }
//    
//    // 시작 시간 처리 - 새로운 ConversationSession 시작
//    private func handleStartTime(_ startTimeString: String) {
//        let formatter = ISO8601DateFormatter()
//        guard let startTime = formatter.date(from: startTimeString) else {
//            print("❌ 시작 시간 파싱 실패: \(startTimeString)")
//            return
//        }
//        
//        // 새로운 세션 시작
//        currentSession = ConversationSession(
//            startTime: startTime,
//            endTime: nil,
//            groups: []
//        )
//        
//        print("✅ 새로운 대화 세션 시작: \(startTime)")
//    }
//    
//    // 종료 시간 처리 - 현재 세션 완료
//    private func handleExitTime(_ exitTimeString: String) {
//        let formatter = ISO8601DateFormatter()
//        guard let exitTime = formatter.date(from: exitTimeString),
//              var session = currentSession else {
//            print("❌ 종료 시간 처리 실패")
//            return
//        }
//        
//        // 현재 세션에 종료 시간 설정
//        session.endTime = exitTime
//        
//        // 완료된 세션을 배열에 추가 (최신순으로 정렬)
//        conversationSessions.insert(session, at: 0)
//        
//        // 현재 세션 초기화
//        currentSession = nil
//        
//        // 저장
//        saveSessions()
//        
//        print("✅ 대화 세션 완료: \(session.startTime) ~ \(exitTime)")
//        print("총 그룹 수: \(session.groups.count)")
//    }
//    
//    // WordSuggestion 배열을 받아서 현재 세션에 그룹으로 추가
//    private func handleReceivedSuggestions(_ suggestions: [WordSuggestion]) {
//        guard !suggestions.isEmpty else { return }
//        
//        // 현재 세션이 없으면 임시로 생성 (혹시 시작 메시지를 놓친 경우)
//        if currentSession == nil {
//            currentSession = ConversationSession(
//                startTime: Date(),
//                endTime: nil,
//                groups: []
//            )
//            print("⚠️ 시작 메시지 없이 제안 수신, 임시 세션 생성")
//        }
//        
//        // 첫 번째 suggestion의 meaning에서 한국어 키워드 추출
//        // 예: "지금, 현재" 같은 형태에서 첫 번째 단어를 키워드로 사용
//        let keyword = extractKeywordFromSuggestions(suggestions)
//        
//        let newGroup = WordSuggestionGroup(
//            keyword: keyword,
//            suggestions: suggestions
//        )
//        
//        currentSession?.groups.append(newGroup)
//        
//        // UI 업데이트용
//        receivedSuggestions = suggestions
//        
//        print("📥 그룹 추가됨 - 키워드: \(keyword), 제안 수: \(suggestions.count)")
//    }
//    
//    // suggestion들로부터 키워드 추출하는 헬퍼 함수
//    private func extractKeywordFromSuggestions(_ suggestions: [WordSuggestion]) -> String {
//        // 첫 번째 suggestion의 meaning에서 한국어 부분을 키워드로 사용
//        // 예: "지금, 현재" -> "지금"
//        if let firstSuggestion = suggestions.first {
//            let meaning = firstSuggestion.meaning
//            if let firstWord = meaning.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) {
//                return firstWord
//            }
//        }
//        return "알 수 없음"
//    }
//    
//    // 세션 저장
//    private func saveSessions() {
//        if let encoded = try? JSONEncoder().encode(conversationSessions) {
//            UserDefaults.standard.set(encoded, forKey: "ConversationSessions")
//        }
//    }
//    
//    // 저장된 세션 불러오기
//    private func loadSavedSessions() {
//        if let data = UserDefaults.standard.data(forKey: "ConversationSessions"),
//           let decoded = try? JSONDecoder().decode([ConversationSession].self, from: data) {
//            conversationSessions = decoded
//        }
//    }
//    
//    // 세션 삭제 (필요시)
//    func deleteSession(at indexSet: IndexSet) {
//        conversationSessions.remove(atOffsets: indexSet)
//        saveSessions()
//    }
//
//    // ✅ iOS에서는 사실 필수는 아님. 로그만 적당히 넣자.
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
//        print("✅ iOS session activation complete. State: \(activationState.rawValue), Error: \(String(describing: error))")
//    }
//
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("ℹ️ sessionDidBecomeInactive")
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("ℹ️ sessionDidDeactivate")
//    }
//}
