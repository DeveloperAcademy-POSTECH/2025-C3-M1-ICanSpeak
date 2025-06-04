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
    @StateObject private var motionManager = MotionManager.shared
    @StateObject var sessionManager = WatchSessionManager.shared
    
    @State private var isDetected = false
    @State private var showVoiceView = false
    @State private var isRetrySpeaking = false
    @State private var viewState = UUID() // 강제 리프레시를 위한 UUID
    
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
                        .onAppear {
                            print("✅ VoiceToTextView 나타남")
                        }
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
                if motionManager.isHandRaised || isRetrySpeaking {
                    showVoiceView = true
                    soundManager.stopDetection()
                    WatchSessionManager.shared.receivedText = "원하는 단어를\n말해보세요."
                    // 다시 말하기일 때 추가 초기화
                    if isRetrySpeaking {
                        viewState = UUID() // 새로운 UUID로 강제 리프레시
                    }
                } else if !motionManager.isHandRaised
                          && sessionManager.receivedText == "원하는 단어를\n말해보세요."
                          && showVoiceView
                          && !isRetrySpeaking {
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
            .onReceive(NotificationCenter.default.publisher(for: .didRequestReturnToDetectionView)) { _ in
                print("📩 WordSuggestionView → FirstDetectView로 복귀")
                showVoiceView = false
                isDetected = false
                isRetrySpeaking = false
                soundManager.startDetection()
                motionManager.startMonitoring()
                viewState = UUID() // 상태 초기화
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestRetrySpeaking)) { _ in
                print("🔁 다시 말하기 트리거됨")
                DispatchQueue.main.async {
                    isDetected = false
                    isRetrySpeaking = true
                    showVoiceView = true
                    motionManager.startRecording()
                    soundManager.stopDetection()
                    // 상태 완전 초기화
                    WatchSessionManager.shared.receivedText = "원하는 단어를\n말해보세요."
                    viewState = UUID() // 새로운 UUID로 강제 리프레시
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
}
