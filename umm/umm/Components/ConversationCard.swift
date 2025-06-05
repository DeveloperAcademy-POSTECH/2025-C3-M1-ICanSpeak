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
        VStack(alignment: .center, spacing: 6, content: {
            timeDuration
            wordBox
        })
        .frame(width: 361, height: 163)
    }

    //MARK: - 시간
    private var timeDuration: some View {
        HStack(alignment: .center, spacing: 5, content: {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
        
            Group {
                if let end = session.endTime {
                    Text("\(TimeLogManager.formatTime(session.startTime)) - \(TimeLogManager.formatTime(end))")
                        .font(.sfregular12)
                        .foregroundStyle(.txt06)
                }
            }
            
            Spacer()
        })
    }

    //MARK: - 대화 박스
    private var wordBox: some View {
        HStack(content: {
            
            Spacer().frame(width: 12)
            
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
                        Image("line")
                    }
                }
            }
            .padding(.vertical)
            .frame(width: 343)
            .background(Color.ummPrimary)
            .cornerRadius(8)
        })
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
}
