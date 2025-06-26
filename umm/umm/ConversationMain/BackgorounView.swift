//
//  BackgorounView.swift
//  umm
//
//  Created by MINJEONG on 6/5/25.
//

import SwiftUI

struct BackgorounView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.primary0
                    .ignoresSafeArea()
                
                Image("background")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 1.4) // 너비를 꽉 채우되 약간 더 크게
                    .offset(y: 100)
                    .offset(x:-100)
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    BackgorounView()
}

