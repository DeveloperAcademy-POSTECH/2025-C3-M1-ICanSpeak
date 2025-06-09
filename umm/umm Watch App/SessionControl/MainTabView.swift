//
//  TabView.swift
//  umm
//
//  Created by Ella's Mac on 6/3/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1

    @EnvironmentObject var pauseManager: PauseManager
    @EnvironmentObject var soundManager: SoundDetectionManager
    @EnvironmentObject var motionManager: MotionManager

    var body: some View {
        TabView(selection: $selectedTab) {
            // 탭 1: 일시정지 / 종료
            PauseView()
                .environmentObject(pauseManager)
                .environmentObject(soundManager)
                .environmentObject(motionManager)
                .tag(0)
                .tabItem {
                    Label("탭1", systemImage: "house")
                }

            // 탭 2: 감지 기능 동작
            DetectionView()
                .environmentObject(pauseManager)
                .environmentObject(soundManager)
                .environmentObject(motionManager)
                .tag(1)
                .tabItem {
                    Label("탭2", systemImage: "gear")
                }
        }
    }
}

//#Preview {
//    MainTabView()
//        .environmentObject(PauseManager())
//}
