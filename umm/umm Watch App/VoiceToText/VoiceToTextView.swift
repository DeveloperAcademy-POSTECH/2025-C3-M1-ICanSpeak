//
//  VoiceToTextView.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import SwiftUI

struct VoiceToTextView: View {
    @StateObject var sessionManager = WatchSessionManager.shared
    
    @StateObject var motionManager = MotionManager()
    
    @State private var showBounce = false

    
    var body: some View {
        VStack(spacing: 10) {
            Text(sessionManager.receivedText)
                .multilineTextAlignment(.center)
                .font(.sdregular16)
            Image(systemName: "waveform")
                .font(.system(size: 30))
                .symbolEffect(.bounce.up.byLayer, value: showBounce)
        }
        .onAppear {
//            motionManager.startMonitoring()
            
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            withAnimation {
                                showBounce = motionManager.isSpeaking
                            }
                        }
        }
    }
}

#Preview {
    VoiceToTextView()
}
