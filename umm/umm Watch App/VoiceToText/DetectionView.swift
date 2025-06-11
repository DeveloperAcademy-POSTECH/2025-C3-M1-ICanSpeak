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
    @State private var isVoiceToTextDone: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        if pauseManager.isPaused {
            Text("일시 정지 중이에요")
                .font(.sdregular16)
                .foregroundColor(.white)
        } else {
            ZStack {
                if isVoiceToTextDone {
                    WordSuggestionView(koreanWord: sessionManager.receivedText)
                } else if showVoiceView {
                    VoiceToTextView(shouldNavigate: $isVoiceToTextDone, isLoading: $isLoading)
                        .id(viewState)
                } else {
                    if isDetected {
                        UmmDetectView(showVoiceView: $showVoiceView)
                            .transition(.opacity)
                            .id("umm")
                    } else {
                        FirstDetectView(showVoiceView: $showVoiceView)
                            .transition(.opacity)
                            .id("first")
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isDetected)
            .onAppear {
                soundManager.pauseManager = pauseManager
                soundManager.startDetection()
            }
            .onChange(of: soundManager.detectedSound) { newVal, _ in
                guard !pauseManager.isPaused else { return }
                guard !showVoiceView && !isVoiceToTextDone else { return }
                
                if newVal.contains("감지됨") || newVal.contains("이상") {
                    isDetected = true
                    WKInterfaceDevice.current().play(.success)
                } else {
                    // 음성이 감지되지 않으면 다시 FirstDetectView로
                    isDetected = false
                }
            }
            .onChange(of: pauseManager.isPaused) { isPaused, _ in
                if isPaused {
                    soundManager.pauseDetection()
                } else {
                    soundManager.resumeDetection()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestAppReset)) { _ in
                soundManager.stopDetection()
                WatchSessionManager.shared.receivedText = ""
                resetAllStates()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestReturnToDetectionView)) { _ in
                resetToDetectionState()
                soundManager.startDetection()
                viewState = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didRequestRetrySpeaking)) { _ in
                isVoiceToTextDone = false
                showVoiceView = true
                isDetected = false  // 재시도 시 감지 상태 초기화
                isRetrySpeaking = true
                soundManager.stopDetection()
                viewState = UUID()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func resetToDetectionState() {
        isVoiceToTextDone = false
        showVoiceView = false
        isDetected = false
        isRetrySpeaking = false
    }
    
    private func resetAllStates() {
        resetToDetectionState()
        viewState = UUID()
    }
}

extension Notification.Name {
    static let didRequestReturnToDetectionView = Notification.Name("didRequestReturnToDetectionView")
    static let didRequestRetrySpeaking = Notification.Name("didRequestRetrySpeaking")
    static let didRequestAppReset = Notification.Name("didRequestAppReset")
}
