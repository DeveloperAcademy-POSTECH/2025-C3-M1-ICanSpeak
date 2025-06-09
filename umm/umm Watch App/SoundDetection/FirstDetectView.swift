//
//  FirstDetectView.swift
//  umm Watch App
//
//  Created by MINJEONG on 5/28/25.
//

import SwiftUI

struct FirstDetectView: View {
    @Binding var showVoiceView: Bool
    @State private var scales: [CGFloat] = [1, 1, 1]
    
    let pulseCount = 3
    let pulseDelay: Double = 1
    
    var body: some View {
        VStack(spacing: 16) {
             ZStack {
                // 👇 1. 배경 애니메이션 (맨 아래)
                ForEach(0..<pulseCount, id: \.self) { index in
                    PulseCircle(delay: Double(index) * pulseDelay)
                }

                // 👇 2. 중앙 동그라미
                Circle()
                    .fill()
                    .foregroundColor(.ummSecondWhite)
                    .frame(width: 100, height: 100)

                // 👇 3. 애니메이션 점들
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(.gray)
                            .frame(width: 6, height: 6)
                            .scaleEffect(scales[index])
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.7)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: scales[index]
                            )
                    }
                }

                // 👇 4. 버튼 (맨 위로 올라오게)
                VStack {
                    Spacer()
                    Button {
                        DispatchQueue.main.async {
                            showVoiceView = true
                        }
                        MotionManager.shared.startRecording()
                        SoundDetectionManager.shared.stopDetection()
                        WatchSessionManager.shared.receivedText = "단어를 물어보세요."
                    } label: {
                        Text("물어보기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .background(
                                        Capsule().fill(Color.gray.opacity(0.7))
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .onAppear {
                for i in 0..<scales.count {
                    scales[i] = 1.4
                }
            }
        }
    }
}


/// 외곽 원 애니메이션
struct PulseCircle: View {
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(.opacity(0.6))
            .frame(width: 100, height: 100)
            .scaleEffect(animate ? 2.0 : 1.0)
            .opacity(animate ? 0.0 : 1.0)
            .animation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: false)
                    .delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}


