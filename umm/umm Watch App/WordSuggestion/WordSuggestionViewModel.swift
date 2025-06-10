//
//  WordSuggestionViewModel.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import Foundation
import WatchConnectivity

class WordSuggestionViewModel: NSObject, ObservableObject, WCSessionDelegate {

    
    @Published var suggestions: [WordSuggestion] = []
    
    
    //MARK: - 필수 작성 함수
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("⌚️ Watch session activated: \(activationState.rawValue), error: \(String(describing: error))")
    }

    //MARK: - Fetch Suggestion
    func fetchSuggestions(for word: String) {
        guard let apiKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
                    print("❌ API 키를 찾을 수 없습니다.")
                    return
                }
        
        if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
            print("✅ API Key Loaded: \(key.prefix(5))...")
        } else {
            print("❌ API Key Not Found")
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        한국어 단어 '\(word)'에 해당하는 영어 표현을 1~3개 추천해줘.  
        단, 실제 원어민들이 일상 대화에서 자주 사용하는 표현만 골라줘.  
        문법적으로 맞지만 실제로 잘 쓰지 않는 표현(fifth month 등)은 제외해줘.
        
        품사는 반드시 아래 목록 중 하나로만 표시해줘:  
        noun, verb, adj, adv, phr, prep, conj, interj, modal  
        띄어쓰기 없이 영어 소문자로 정확히 써줘. (예: phrasal verb ❌ / phr ✅)
        
        그리고 단어 자체가 특정한 뉘앙스나 사용 상황을 강하게 가지는 경우에만,  
        그 특징을 괄호로 간단히 덧붙여줘. 일반적인 의미와 거의 차이가 없다면 생략해도 좋아.

        각 표현은 아래 형식으로 설명해줘:

        • 영어 단어 또는 표현 – (품사) 자연스러운 한국어 의미 (필요한 경우에만 뉘앙스 추가)  
        예문: 자연스럽고 짧은 영어 예문 1개
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, _, error in
            print("🔥 API 요청 시작")

            guard let data = data else {
                print("❌ 데이터 없음: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                print("🧾 GPT 응답 원문:\n\(raw)")
            }

            guard let result = try? JSONDecoder().decode(GPTResponse.self, from: data),
                  let content = result.choices.first?.message.content else {
                print("❌ JSON 디코딩 실패")
                return
            }

            print("✅ 파싱된 콘텐츠:\n\(content)")

            let parsed = self.parseGPTResponse(content)

            DispatchQueue.main.async {
                self.suggestions = parsed
            }
        }.resume()
    }

    // MARK: - 파싱 함수
    private func parseGPTResponse(_ content: String) -> [WordSuggestion] {
        let rawItems = content.components(separatedBy: "• ").filter { !$0.isEmpty }
        var suggestions: [WordSuggestion] = []

        // Updated regex to allow hyphen, en dash, em dash and flexible spacing
        let pattern = #"^([a-zA-Z\s]+)\s+[–—-]\s+\((\w+)\)\s+(.+)$"#
        let regex = try! NSRegularExpression(pattern: pattern)

        for item in rawItems {
            let lines = item.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }
            guard lines.count >= 2 else { continue }

            let firstLine = lines[0]
            let secondLine = lines[1]

            if let match = regex.firstMatch(in: firstLine, range: NSRange(location: 0, length: firstLine.utf16.count)) {
                let word = (firstLine as NSString).substring(with: match.range(at: 1))
                let pos = (firstLine as NSString).substring(with: match.range(at: 2))
                let meaning = (firstLine as NSString).substring(with: match.range(at: 3))
                let example = secondLine.replacingOccurrences(of: "예문:", with: "").trimmingCharacters(in: .whitespaces)

                suggestions.append(
                    WordSuggestion(word: word, partOfSpeech: pos, meaning: meaning, example: example)
                )
            } else {
                print("❌ 파싱 실패한 줄:\n\(firstLine)")
            }
        }

        return suggestions
    }
}
