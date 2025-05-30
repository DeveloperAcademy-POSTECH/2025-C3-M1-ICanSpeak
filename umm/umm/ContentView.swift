//
//  ContentView.swift
//  umm
//
//  Created by Youbin on 5/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var receiver = PhoneMessageReceiver()
    var body: some View {
        NavigationView {
            List(receiver.receivedSuggestions) { suggestion in
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.word)
                        .font(.headline)

                    Text("\(suggestion.partOfSpeech) • \(suggestion.meaning)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("예문: \(suggestion.example)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("추천 단어")
        }
    }
}
