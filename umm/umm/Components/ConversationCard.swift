//
//  ConversationCard.swift
//  umm
//
//  Created by Youbin on 6/5/25.
//

import SwiftUI

struct ConversationCard: View {
    let session: ConversationSession

    var body: some View {
        VStack(content: {
            timeDuration
            wordBox
        })
    }

    //MARK: - 시간
    private var timeDuration: some View {
        HStack(alignment: .center, spacing: 4, content: {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
        
            Group {
                if let end = session.endTime {
                    Text("\(TimeLogManager.formatTime(session.startTime)) - \(TimeLogManager.formatTime(end))")
                        .font(.sfregular12)
                        .foregroundColor(.gray)
                }
            }
        })
    }

    //MARK: - 대화 박스
    private var wordBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(session.groups.indices, id: \.self) { index in
                let group = session.groups[index]

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.keyword)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(group.suggestions.map { $0.word }.joined(separator: " | "))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                // 마지막 그룹 뒤에는 Divider 안 붙임
                if index != session.groups.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.3))
                }
            }
        }
        .padding()
        .background(Color.orange)
        .cornerRadius(12)
    }
}

#Preview {
    ConversationCard(session: ConversationSession(
        startTime: Date(),
        endTime: Calendar.current.date(byAdding: .minute, value: 20, to: Date()),
        groups: [
            WordSuggestionGroup(
                keyword: "초대하다",
                suggestions: [
                    WordSuggestion(word: "invite", partOfSpeech: "v", meaning: "초대하다", example: "I invited them."),
                    WordSuggestion(word: "ask over", partOfSpeech: "phr", meaning: "집에 초대하다", example: "I asked her over."),
                    WordSuggestion(word: "welcome", partOfSpeech: "v", meaning: "환영하다", example: "They welcomed us.")
                ]
            ),
            WordSuggestionGroup(
                keyword: "5월",
                suggestions: [
                    WordSuggestion(word: "May", partOfSpeech: "n", meaning: "5월", example: "We met in May."),
                    WordSuggestion(word: "in May", partOfSpeech: "phr", meaning: "5월에", example: "I was born in May.")
                ]
            )
        ]
    ))
    .padding()
    .background(Color.black)
}
