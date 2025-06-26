//
//  ummApp.swift
//  umm Watch App
//
//  Created by Youbin on 5/27/25.
//

import SwiftUI

@main
struct umm_Watch_AppApp: App {
    init() {
        print("🧪 앱 시작 - WatchSessionManager 초기화")
        _ = WatchSessionManager.shared  // 세션 강제 초기화
    }

    @StateObject private var pauseManager = PauseManager()
    @StateObject private var soundManager = SoundDetectionManager.shared
    @StateObject private var audioManager = AudioManager.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(pauseManager)
                .environmentObject(soundManager)
                .environmentObject(audioManager)
                .onChange(of: pauseManager.isPaused) {
                    if pauseManager.isPaused {
                        print("🥱 App Level: 일시정지 감지")
                        audioManager.pauseRecording()
                        soundManager.pauseDetection()
                    } else {
                        print("😎 App Level: 재개 감지")
                        audioManager.resumeRecording()
                        soundManager.resumeDetection()
                    }
                }
        }
    }
}
