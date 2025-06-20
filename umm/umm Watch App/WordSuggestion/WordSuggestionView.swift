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
            VStack(spacing: 4) {
                koreanWords
                englishWordListConditional
                btns
            }
        }
        .padding(.top, -13)
        .background(Color.black)
        .onAppear {
                    // MARK: - ⭐ 음성인식 실패 시 검색 방지 ⭐
                    if koreanWord != "음성인식 실패" {
                        viewModel.fetchSuggestions(for: koreanWord)
                    } else {
                        // ⚠️ 음성인식 실패 메시지를 받았으므로 GPT API 호출을 건너뜁니다
                    }
                    activateWatchSession()
                }
    }

    //MARK: - 한국어 단어
    private var koreanWords: some View {
        Text(koreanWord)
            .font(.sdregular16)
    }

    //MARK: - 영어 단어 (단어만 표시) - 조건부 렌더링
    private var englishWordListConditional: some View {
        Group {
            if koreanWord != "음성인식 실패" {
                if viewModel.suggestions.isEmpty {
                      ProgressView()
                } else {
                    englishWordList
                }
            }
        }
    }

    private var englishWordList: some View {
        ForEach(viewModel.suggestions) { suggestion in
            HStack {
                Text(suggestion.word)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 7)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 8)
            .background(Color.white.opacity(0.12))
            .cornerRadius(8.5)
        }
    }

    //MARK: - 버튼들
    private var btns: some View {
        VStack(spacing: 2) {
          if koreanWord != "음성인식 실패" {
                          Button(action: {
                              sendSuggestionsToiPhone(viewModel.suggestions)
                              NotificationCenter.default.post(name: .didRequestReturnToDetectionView, object: nil)
                          }, label: {
                              Text("확인")
                                  .frame(width: 150, height: 45)
                                  .font(.sdmedium16)
                                  .foregroundStyle(Color.white)
                          })
                          .buttonStyle(.borderedProminent)
                          .tint(.ummPrimary.opacity(0.85))
                      } else {
                          Spacer().frame(height: 45 + 2) // 버튼 높이(45)와 VStack spacing(2)을 고려
                      }
            Button(action: {
                //TODO: - 다시 말하기 동작
                NotificationCenter.default.post(name: .didRequestRetrySpeaking, object: nil)

            }, label: {
                Text("다시 말하기")
                    .frame(width: 150, height: 45)
                    .font(.sdmedium16)
                    .foregroundStyle(Color.white)
            })
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
            WCSession.default.sendMessage([
                "suggestions": data,
                "keyword": koreanWord // ✅ 추가!
            ], replyHandler: nil) { error in
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
