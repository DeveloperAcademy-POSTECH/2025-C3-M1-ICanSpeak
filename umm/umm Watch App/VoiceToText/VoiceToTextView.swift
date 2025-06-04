//
//  VoiceToTextView.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import SwiftUI

struct VoiceToTextView: View {
    @StateObject var sessionManager = WatchSessionManager.shared
    @StateObject var motionManager = MotionManager.shared
    @State private var showBounce = false
    @State private var shouldNavigate = false

    
    var body: some View {
        Group {
            if shouldNavigate {
                WordSuggestionView(koreanWord: sessionManager.receivedText)
            } else {
                VStack(spacing: 10) {
                    Text(sessionManager.receivedText)
                        .multilineTextAlignment(.center)
                        .font(.sdregular16)
                    
                    Image(systemName: "waveform")
                        .font(.system(size: 30))
                        .symbolEffect(.bounce.up.byLayer, value: showBounce)
                }
                .onAppear {
                    shouldNavigate = false
                    
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                        withAnimation {
                            showBounce = motionManager.isSpeaking
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .didRequestRetrySpeaking)) { _ in
                    shouldNavigate = false
                    motionManager.didFinishRecording = false
                }
                .onChange(of: motionManager.didFinishRecording) {
                    if sessionManager.receivedText != "원하는 단어를\n말해보세요." && !sessionManager.receivedText.isEmpty {
                        shouldNavigate = true
                    }
                }
                .onChange(of: sessionManager.receivedText) {
                    if sessionManager.receivedText != "원하는 단어를\n말해보세요." && !sessionManager.receivedText.isEmpty {
                        shouldNavigate = true
                    }
                }
                .onChange(of: shouldNavigate) {
                    if shouldNavigate {
                        motionManager.stopMonitoring()
                    }
                }
            }
        }
        
    }
}

