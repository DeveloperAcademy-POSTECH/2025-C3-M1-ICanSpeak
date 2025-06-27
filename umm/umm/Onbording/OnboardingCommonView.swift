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
    var imageOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    Text(title)
                        .frame(minHeight: 80)
                        .font(.title)
                        .bold()
                        .foregroundColor(.txt07)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.sdregular19)
                        .foregroundColor(.txt05)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 50)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 40)
                    .frame(maxHeight: geometry.size.height * 0.5)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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
