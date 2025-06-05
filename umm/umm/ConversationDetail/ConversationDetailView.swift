//
//  ConversationDetailView.swift
//  umm
//
//  Created by Youbin on 6/5/25.
//

import SwiftUI

struct ConversationDetailView: View {
    let session: ConversationSession

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(session.groups) { group in
                    WordsCard(group: group)
                }
            }
            .padding()
        }
        .navigationTitle("대화 상세")
    }
}
