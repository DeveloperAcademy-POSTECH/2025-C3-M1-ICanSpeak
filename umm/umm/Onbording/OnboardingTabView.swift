//
//  OnboardingTabView.swift
//  onboarding
//
//  Created by MINJEONG on 6/4/25.
//

import SwiftUI

struct OnboardingTabView: View {
    @Binding var isFirstOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        VStack {
            Spacer().frame(height: 39)

            HStack(spacing: 10) {
                ForEach(0..<4) { index in
                    Circle()
                        .fill(index == currentPage ? Color.ummPrimary : Color.fld05)
                        .frame(width: 7, height: 7)
                }
            }

            Spacer().frame(height: 72)

            ZStack {
                switch currentPage {
                case 0:
                    OnboardingCommonView(
                        title: "전화 영어,\n더 이상 두렵지 않게",
                        subtitle: "생각이 안나서 머뭇거리는 순간,\n저희가 도와드릴게요",
                        imageName: "onboarding1"
                    )
                case 1:
                    OnboardingCommonView(
                        title: "‘음…’ 하면\n 알아차려요",
                        subtitle: "대화 중 머뭇거리면 애플워치가 감지해요\n워치에게 모르는 단어를 말하면, 추천단어를 알려줘요",
                        imageName: "onboarding2"
                    )
                case 2:
                    OnboardingCommonView(
                        title: "놓치지 않도록,\n자동 저장",
                        subtitle: "물어봤던 단어는 모두 앱에 기록돼요\n대화 이후 다시 확인해봐요",
                        imageName: "onboarding3"
                    )
                case 3:
                    OnboardingCommonView(
                        title: "모르는 단어,\n예문으로 확실하게",
                        subtitle: "뜻부터 유의어, 품사, 예문까지!\n단어를 눌러 확인할 수 있어요",
                        imageName: "onboarding4"
                    )
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: currentPage)
            .transition(.slide)

            Spacer()

            HStack {
                if currentPage > 0 {
                    Button("이전") {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    }.foregroundColor(.txt03)
                        .frame(width: 74, height: 44)
                }

                Spacer()

                Button(currentPage == 3 ? "확인" : "다음") {
                    if currentPage < 3 {
                        currentPage += 1
                    } else {
                        isFirstOnboarding = false
                    }
                }
                .foregroundStyle(.txt01)
                .bold()
                .frame(width: 74, height: 44)
                .background(Color.ummPrimary)
                    .cornerRadius(25)
                    
            }
            .padding(.horizontal, 14)
             .padding(.bottom, 32)
           
        }
    }
}

#Preview {
    OnboardingTabView(isFirstOnboarding: .constant(true))
}
