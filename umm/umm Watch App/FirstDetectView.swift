//
//  FirstDetectView.swift
//  umm Watch App
//
//  Created by MINJEONG on 5/28/25.
//

import SwiftUI

struct FirstDetectView: View {
    @State private var currentDot = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Circle()
                  .foregroundColor(.gray1)
                  .frame(width: 223, height: 223)
            Circle()
                .foregroundColor(.gray2)
                  .frame(width: 161, height: 161)
            Circle()
                  .foregroundColor(.gray3)
                  .frame(width: 97, height: 97)
            
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentDot == index ? Color.white : Color.gray4)
                            .frame(width: 12, height: 12)
                            .animation(.easeInOut(duration: 0.3), value: currentDot)
                    }
                }
                Spacer()
            }
        }
        .onReceive(timer) { _ in
            currentDot = (currentDot + 1) % 3
        }
    }
}

#Preview {
    FirstDetectView()
}
