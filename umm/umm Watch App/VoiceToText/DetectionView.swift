//
//  MainView.swift
//  umm Watch App
//
//  Created by Ella's Mac on 5/30/25.
//

import SwiftUI
import WatchKit

struct DetectionView: View {
    @EnvironmentObject var pauseManager: PauseManager // 추가
    @StateObject private var soundManager = SoundDetectionManager()
    @StateObject private var motionManager = MotionManager()

    @State private var isDetected = false
    @State private var showVoiceView = false

    var body: some View {
        if pauseManager.isPaused {
            Text("⏸ 일시정지 중")
                .font(.headline)
                .foregroundColor(.gray)
        } else {
            ZStack {
                if showVoiceView {
                    VoiceToTextView()
                } else {
                    if isDetected {
                        UmmDetectView()
                    } else {
                        FirstDetectView()
                    }
                }
            }
            .onAppear {
                soundManager.pauseManager = pauseManager
                soundManager.startDetection()
                motionManager.startMonitoring()
            }
            .onChange(of: soundManager.detectedSound) {
                // 일시정지 상태면 무시
                guard !pauseManager.isPaused else { return }

                if soundManager.detectedSound.contains("감지됨") || soundManager.detectedSound.contains("etc") {
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
                if motionManager.isHandRaised {
                    showVoiceView = true
                    soundManager.stopDetection()
                    WatchSessionManager.shared.receivedText = "원하는 단어를\n말해보세요."
                } else {
                    showVoiceView = false
                    soundManager.startDetection()
                }
            }
            .onChange(of: pauseManager.isPaused) {
                if pauseManager.isPaused {
                    motionManager.stopMonitoring()
                    soundManager.stopDetection()
                } else {
                    motionManager.startMonitoring()
                    soundManager.startDetection()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestAppReset)) { _ in
                motionManager.stopMonitoring()
                soundManager.stopDetection()
                print("🛑 감지 완전 종료됨 (앱 리셋)")
                WatchSessionManager.shared.receivedText = ""
            }
        }
    }
}

#Preview {
    DetectionView()
        .environmentObject(PauseManager())
}
