//
//  ConversationDetailView.swift
//  umm
//
//  Created by Youbin on 6/5/25.
//

import SwiftUI

struct ConversationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ConversationSession
    
    @State private var searchText: String = ""
    
    //MARK: - 검색 필터
    var filteredGroups: [WordSuggestionGroup] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmed.isEmpty else { return session.groups }

        return session.groups.filter { group in
            group.keyword.lowercased().contains(trimmed) ||
            group.suggestions.contains { $0.word.lowercased().contains(trimmed) }
        }
    }

    var body: some View {
        ZStack(content: {
            
            BackgorounView()
            
            VStack(alignment: .center, content: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.textFieldTxt)
                    TextField("한글 단어를 입력해주세요", text: $searchText)
                        .foregroundColor(.textFieldTxt)
                        .font(.sdmedium14)
                }
                .frame(width: 355, height: 36)
                .padding(.vertical, 2)
                .padding(.leading, 5)
                .background(.textFieldBack)
                .cornerRadius(10)
                
                
                ScrollView {
                    VStack(spacing: 60, content: {
                        ForEach(filteredGroups) { group in
                            WordsCard(group: group)
                        }
                    })
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            })
        })
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 18)
                        .padding(.leading, 7)
                        .foregroundColor(.txt06)
                }
                .padding(.top, 15)
                .padding(.bottom, 20)
            }
            ToolbarItem(placement: .principal) {
                Text(session.startTime.formatForDetailHeader())
                    .font(.sfregular14)
                    .foregroundStyle(.txt04)
                    .padding(.top, 15)
                    .padding(.bottom, 20)
            }
        }
    }
}
