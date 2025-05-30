//
//  WordSuggestionView.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import SwiftUI
import WatchConnectivity

struct WordSuggestionView: View {
    let koreanWord: String
    @StateObject private var viewModel = WordSuggestionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                koreanWords
                englishWordList
                btns
            }
        }
        .padding(.top, -20)
        .background(Color.black)
        .onAppear {
            viewModel.fetchSuggestions(for: koreanWord)
            activateWatchSession()
        }
    }

    //MARK: - 한국어 단어
    private var koreanWords: some View {
        Text(koreanWord)
            .font(.system(size: 30))
    }

    //MARK: - 영어 단어 (단어만 표시)
    private var englishWordList: some View {
        ForEach(viewModel.suggestions) { suggestion in
            Text(suggestion.word) // ✨ 핵심: word만 표시
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.7))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
    }

    //MARK: - 버튼들
    private var btns: some View {
        VStack(spacing: 6) {
            Button("확인") {
                sendSuggestionsToiPhone(viewModel.suggestions)
            }
            .buttonStyle(.bordered)
            .tint(.white)

            Button("다시 말하기") {
                // 다시 말하기 동작
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
    }
    
    //MARK: - Functions
    /// 전송 함수
    private func sendSuggestionsToiPhone(_ suggestions: [WordSuggestion]) {
        guard WCSession.default.isReachable else {
            print("📡 iPhone 연결 안 됨")
            return
        }

        do {
            let data = try JSONEncoder().encode(suggestions)
            WCSession.default.sendMessage(["suggestions": data], replyHandler: nil) { error in
                print("❌ 전송 실패: \(error.localizedDescription)")
            }
        } catch {
            print("❌ 인코딩 실패: \(error)")
        }
    }
    
    /// WCSession 활성화 (onAppear에 필요)
    private func activateWatchSession() {
        if WCSession.isSupported() {
            WCSession.default.activate()
        }
    }
    
}
