//
//  WordsCard.swift
//  umm
//
//  Created by Youbin on 6/5/25.
//

import SwiftUI

struct WordsCard: View {
    let group: WordSuggestionGroup

    var body: some View {
        ZStack(alignment: .top, content: {
            
            englishWords
                .offset(y:42)
            
            koreanWordTitle
        })
        .frame(width: 355)
    }
    
    private var koreanWordTitle: some View {
        Text(group.keyword)
            .font(.sdbold19)
            .frame(width: 355, height: 43, alignment: .center)
            .foregroundStyle(.white)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    topTrailingRadius: 12
                )
                .fill(Color.ummPrimary)
            )
            
    }
    
    private var englishWords: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(group.suggestions) { suggestion in
                VStack(alignment: .leading, spacing: 8) {
                    Text(suggestion.word.capitalized)
                        .font(.montBold28)
                    
                    HStack(alignment: .center ,spacing: 6,content: {
                            Text(suggestion.partOfSpeech)
                                .font(.sfmedium12)
                                .foregroundStyle(.txtPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.primary1)
                                .cornerRadius(4)

                            Text(suggestion.meaning)
                                .foregroundStyle(Color.txtPrimary)
                                .font(.sdmedium14)
                    })

                    Text(suggestion.example)
                        .foregroundStyle(Color.txt05)
                        .font(.sfregular14)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if suggestion.id != group.suggestions.last?.id {
                    Divider()
                        .frame(height: 2)
                        .background(.primary1)
                }
            }
        }
        .padding()
        .frame(width: 353)
        .background(
            UnevenRoundedRectangle(
                bottomLeadingRadius: 12,
                bottomTrailingRadius: 12
            )
            .fill(Color.white)
            .overlay(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12
                )
                .stroke(.primary2, lineWidth: 2) // 테두리
            )
        )
    }
}

#Preview {
    WordsCard(group: WordSuggestionGroup(
        keyword: "초대하다",
        suggestions: [
            WordSuggestion(
                word: "invite",
                partOfSpeech: "Verb",
                meaning: "초대하다",
                example: "We invited all our friends to the wedding."
            ),
            WordSuggestion(
                word: "ask over",
                partOfSpeech: "Noun",
                meaning: "(친근하게) 집으로 부르다",
                example: "I’m going to ask Tom over for dinner tonight."
            ),
            WordSuggestion(
                word: "welcome",
                partOfSpeech: "Verb",
                meaning: "맞이하다, 환영하다",
                example: "They welcomed us with big smiles."
            )
        ]
    ))
}
