//
//  VoiceToTextView.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import SwiftUI

struct VoiceToTextView: View {
    @ObservedObject var sessionManager = WatchSessionManager.shared
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var soundManager: SoundDetectionManager

    @Binding var shouldNavigate: Bool
    @Binding var isLoading: Bool

    @State private var showBounce = false

    var body: some View {
        Group {
            if shouldNavigate {
                WordSuggestionView(koreanWord: sessionManager.receivedText)
            } else {
                VStack(spacing: 16) {
                    // ❌ X 버튼: 감지 뷰로 돌아가기
                    HStack {
                        Button(action: {
                            audioManager.stopRecording()
                            isLoading = false
                            NotificationCenter.default.post(name: .didRequestReturnToDetectionView, object: nil)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        }
                        .buttonStyle(.plain)

                        Spacer()
                    }

                    // 🎙️ 텍스트
                    Text(sessionManager.receivedText)
                        .multilineTextAlignment(.center)
                        .font(.headline)

                    // 🎧 애니메이션
                    Image(systemName: "waveform")
                        .font(.system(size: 30))
                        .symbolEffect(.bounce.up.byLayer, value: showBounce)

                    // 🔄 로딩 or 완료 버튼
                    if isLoading {
                        ProgressView("잠시만요...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    } else {
                        Button("완료") {
                            isLoading = true
                            audioManager.stopRecording()
                            print("⏳ 완료 버튼 클릭됨, 텍스트 수신 대기 중...")
                        }
                        .font(.headline)
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    sessionManager.receivedText = "단어를 물어보세요."
                    audioManager.startRecording()

                    // 🔁 애니메이션 타이머
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                        withAnimation {
                            showBounce = audioManager.isRecording
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .didRequestRetrySpeaking)) { _ in
                    shouldNavigate = false
                    isLoading = false
                    sessionManager.receivedText = "단어를 물어보세요."  // 초기화!

                    audioManager.startRecording()
                }
                .onChange(of: sessionManager.receivedText) { _, newText in
                    let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !shouldNavigate &&
                        trimmed != "단어를 물어보세요." &&
                        !trimmed.isEmpty {
                        isLoading = false
                        shouldNavigate = true
                        print("✅ 유효한 텍스트 수신됨 → 전환")
                    }
                }
            }
        }
    }
}
