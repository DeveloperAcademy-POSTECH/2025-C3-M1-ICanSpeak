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
                .foregroundColor(.circlegray).opacity(0.44)
                
                  .frame(width: 133, height: 133)
            Circle()
                .foregroundColor(.circlegray).opacity(0.73)

                  .frame(width: 112, height: 112)
            Circle()
                  .foregroundColor(.circlegray)
                  .frame(width: 84, height: 84)
            
            VStack {
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentDot == index ? Color.white : Color.black)
                            .frame(width: 5, height: 5)
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
