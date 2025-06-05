//
//  DetectionView.swift
//  umm Watch App
//
//  Created by Ella's Mac on 5/30/25.
//

import SwiftUI
import WatchKit

struct DetectionView: View {
    @EnvironmentObject var pauseManager: PauseManager
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var soundManager: SoundDetectionManager

    @StateObject private var sessionManager = WatchSessionManager.shared

    @State private var isDetected: Bool = false
    @State private var showVoiceView: Bool = false
    @State private var isRetrySpeaking: Bool = false
    @State private var viewState = UUID()
    @State private var showPauseSheet: Bool = false

    var body: some View {
        if pauseManager.isPaused {
            Text("⏸ 일시정지 중")
                .font(.headline)
                .foregroundColor(.gray)
        } else {
            ZStack {
                if showVoiceView {
                    VoiceToTextView()
                        .id(viewState) // UUID로 강제 리프레시
                      
                } else {
                    if isDetected {
                        UmmDetectView()
                            .id("umm")
                    } else {
                        FirstDetectView()
                            .id("first")
                    }
                }
            }
            .onAppear {
                soundManager.pauseManager = pauseManager
                motionManager.pauseManager = pauseManager

                soundManager.startDetection()
                motionManager.startMonitoring()
            }
            .onChange(of: soundManager.detectedSound) { newVal, _ in
                guard !pauseManager.isPaused else { return }

                // ‘Um’ 혹은 ‘etc’ 등 감지가 들어오면 isDetected 플래그 true로 바꾸고, 성공 햅틱
                if newVal.contains("감지됨") || newVal.contains("3초 이상 기타") {
                    isDetected = true
                    WKInterfaceDevice.current().play(.success)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if !motionManager.isHandRaised {
                            isDetected = false
                        }
                    }
                }
            }
            .onChange(of: motionManager.isHandRaised) {
                if (motionManager.isHandRaised || isRetrySpeaking) {
                    // 손 올라갔거나 재시도 상태인 경우
                    showVoiceView = true
                    motionManager.startRecording()
                    soundManager.pauseDetection()
                    WatchSessionManager.shared.receivedText = "원하는 단어를\n말해보세요."

                    if isRetrySpeaking {
                        viewState = UUID() // 강제 리프레시
                    }
                }
                else if !motionManager.isHandRaised
                            && sessionManager.receivedText == "원하는 단어를\n말해보세요."
                            && showVoiceView
                            && !isRetrySpeaking {
                    showVoiceView = false
                    soundManager.startDetection()
                }
            }
            .onChange(of: pauseManager.isPaused) { isPaused, _ in
                if isPaused {
                    print("⏸️ 일시정지 - 모든 감지 중단")
                    motionManager.pauseRecording()     // 모션 업데이트 & 녹음 완전 중단
                    soundManager.pauseDetection()      // 소리 감지 완전 중단
                } else {
                    print("▶️ 재개 - 모든 감지 시작")
                    motionManager.resumeRecording()    // 녹음 관련 초기화
                    motionManager.startMonitoring()    // 모션 업데이트 재개
                    soundManager.resumeDetection()     // 소리 감지 재개
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestAppReset)) { _ in
                motionManager.stopMonitoring()
                soundManager.stopDetection()
                print("🛑 감지 완전 종료됨 (앱 리셋)")
                WatchSessionManager.shared.receivedText = ""
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestReturnToDetectionView)) { _ in
                print("📩 WordSuggestionView → FirstDetectView로 복귀")
                showVoiceView = false
                isDetected = false
                isRetrySpeaking = false
                soundManager.startDetection()
                motionManager.startMonitoring()
                viewState = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestRetrySpeaking)) { _ in
                print("🔁 다시 말하기 트리거됨")
                DispatchQueue.main.async {
                    isDetected = false
                    isRetrySpeaking = true
                    showVoiceView = true
                    motionManager.startRecording()
                    soundManager.stopDetection()
                    WatchSessionManager.shared.receivedText = "원하는 단어를\n말해보세요."
                    viewState = UUID()
                }
            }
        }
    }
}

extension Notification.Name {
    static let didRequestReturnToDetectionView = Notification.Name("didRequestReturnToDetectionView")
    static let didRequestRetrySpeaking = Notification.Name("didRequestRetrySpeaking")
}

#Preview {
    DetectionView()
        .environmentObject(PauseManager())
        .environmentObject(MotionManager.shared)
        .environmentObject(SoundDetectionManager.shared)
}
