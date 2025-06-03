//
//  MainView.swift
//  umm Watch App
//
//  Created by Ella's Mac on 5/30/25.
//

import SwiftUI

struct MainView: View {
@StateObject private var motionManager = MotionManager()
@StateObject private var soundDetectionManager = SoundDetectionManager()  // ✅ 소리 감지 매니저 추가

var body: some View {
    VStack {
        if motionManager.isHandRaised {
            VoiceToTextView()
        } else {
            SoundDetectMainView()
                .environmentObject(soundDetectionManager)  // ✅ 필요시 전달
        }
    }
    .onAppear {
        motionManager.startMonitoring()
        // 앱 처음 실행 시 감지 준비
        soundDetectionManager.startDetection()
    }
    .onChange(of: motionManager.isHandRaised) { isRaised in
        if isRaised {
            // 손 올렸을 때: 소리 감지 중지
            soundDetectionManager.stopDetection()
        } else {
            // 손 내렸을 때: 소리 감지 다시 시작
            soundDetectionManager.startDetection()
        }
    }
}

}


//    #Preview {
//        MainView()
//    }

