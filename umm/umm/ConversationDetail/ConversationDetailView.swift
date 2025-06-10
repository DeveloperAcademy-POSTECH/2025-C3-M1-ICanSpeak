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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(session.groups) { group in
                    WordsCard(group: group)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 10, height: 18)
                        .padding(.leading, 5)
                        .foregroundColor(.txt06)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(session.startTime.formatForDetailHeader())
                    .font(.sfregular14)
                    .foregroundStyle(.txt04)
            }
        }
    }
}
