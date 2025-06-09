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
                ForEach(0..<5) { index in
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
                        imageName: "onboarding1",
                        imageOffset: 20
                    )
                case 1:
                    OnboardingCommonView(
                        title: "‘음…’ 하면\n손목에 질문이 올려요",
                        subtitle: "버튼을 눌러 워치에게\n모르는 단어를 물어보세요",
                        imageName: "onboarding2"
                    )
                case 2:
                    OnboardingCommonView(
                        title: "딱 맞는 단어를\n똑똑하게 추천해요",
                        subtitle: "AI가 어울리는 영어 단어를\n최대 3개까지 추천해줘요",
                        imageName: "onboarding3"
                    )
                case 3:
                    OnboardingCommonView(
                        title: "모르는 단어,\n예문으로 확실하게",
                        subtitle: "뜻부터 유의어, 품사, 예문까지!\n단어를 눌러 확인할 수 있어요",
                        imageName: "onboarding4"
                    )
                case 4:
                    OnboardingCommonView(
                        title: "모르는 단어,\n예문으로 확실하게",
                        subtitle: "뜻부터 유의어, 품사, 예문까지!\n단어를 눌러 확인할 수 있어요",
                        imageName: "onboarding5"
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
                        .font(.sdbold16)
                        .frame(width: 74, height: 44)
                }

                Spacer()

                Button(currentPage == 4 ? "확인" : "다음") {
                    if currentPage < 4 {
                        currentPage += 1
                    } else {
                        isFirstOnboarding = false
                    }
                }
                .foregroundStyle(.txt01)
                .font(.sdbold16)
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
