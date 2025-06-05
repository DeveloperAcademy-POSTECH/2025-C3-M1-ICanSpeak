//
//  OnboardingCommonView.swift
//  onboarding
//
//  Created by MINJEONG on 6/4/25.
//

import SwiftUI

struct OnboardingCommonView: View {
    let title: String
    let subtitle: String
    let imageName: String
    
    var body: some View {
        VStack {
            VStack(spacing: 16) { // 텍스트 간 사이 간격
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.txt07)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.sdregular15)
                    .foregroundColor(.txt05)
                    .multilineTextAlignment(.center)
            }
            Spacer().frame(height: 50) // 텍스트 사진 간격
            Image(imageName)
              

        
        }
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        OnboardingCommonView(
            title: "전화 영어,\n더 이상 두렵지 않게",
            subtitle: "생각이 안나서 머뭇거리는 순간,\n저희가 도와드릴게요",
            imageName: "onboarding1"
        )
    }
}
