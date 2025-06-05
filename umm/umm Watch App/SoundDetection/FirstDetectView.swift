//
//  FirstDetectView.swift
//  umm Watch App
//
//  Created by MINJEONG on 5/28/25.
//

import SwiftUI

struct FirstDetectView: View {
    @State private var currentDot = 0
    @State private var animate = false
    @State private var scales: [CGFloat] = [1, 1, 1]

    let pulseCount = 3
    let pulseDelay: Double = 1
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            ForEach(0..<pulseCount, id: \.self) { index in
                PulseCircle(delay: Double(index) * pulseDelay)
            }
            Circle()
                .fill()
                .foregroundColor(.ummSecondWhite)
                .frame(width: 100, height: 100)
            
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
                    .onAppear {
                        for i in 0..<scales.count {
                            scales[i] = 1.4
                        }
                    }
                }

    }
}

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

#Preview {
    FirstDetectView()
}
