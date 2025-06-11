//
// UmmDetectView.swift
//  WatchTest29th Watch App
//
//  Created by MINJEONG on 5/29/25.
//

import SwiftUI

struct UmmDetectView: View {
    @Binding var showVoiceView: Bool
    var body: some View {
        ZStack{
            
            Circle()
                .foregroundColor(.orange).opacity(0.4)
            Circle()
                .foregroundColor(.orange).opacity(0.7)
                .padding(15)
            Circle()
                .foregroundColor(.orange)
                .padding(30)
            
            Text("Umm")
                .font(.sfbold20)

            VStack {
                Spacer()
                
                Button{
                    DispatchQueue.main.async {
                        showVoiceView = true
                    }
                    MotionManager.shared.startRecording()
                    SoundDetectionManager.shared.stopDetection()
                    WatchSessionManager.shared.receivedText = "단어를 물어보세요."
                } label: {
                    Text("물어보기")
                        .font(.headline)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .background(
                                    Capsule().fill(Color.gray.opacity(0.4))
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}




//#Preview {
//    UmmDetectView()
//}
