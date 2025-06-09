//
//  FirstDetectView.swift
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
                .foregroundColor(.ummPrimary).opacity(0.4)
            
                .frame(width: 100, height: 100)
            Circle()
                .foregroundColor(.ummPrimary).opacity(0.7)
            
                .frame(width: 80, height: 80)
            Circle()
                .foregroundColor(.ummPrimary)
                .frame(width: 70, height:70)
            
            Text("Umm")
                .font(.headline)
            
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
