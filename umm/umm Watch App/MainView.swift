//
//  MainView.swift
//  umm Watch App
//
//  Created by Ella's Mac on 5/30/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var motionManager = MotionManager()
    
    var body: some View {
        VStack {
            if motionManager.isHandRaised {
                VoiceToTextView()
            } else {
                SoundDetectMainView()
            }
        }
        .onAppear {
        motionManager.startMonitoring()
            }
    }
}

#Preview {
    MainView()
}
