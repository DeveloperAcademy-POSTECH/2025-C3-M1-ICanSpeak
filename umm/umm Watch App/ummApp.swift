//
//  ummApp.swift
//  umm Watch App
//
//  Created by Youbin on 5/27/25.
//

import SwiftUI

@main
struct umm_Watch_AppApp: App {
    init() {
           print("🧪 앱 시작 - WatchSessionManager 초기화")
           _ = WatchSessionManager.shared  // 세션 강제 초기화
       }
    
    var body: some Scene {
        WindowGroup {
            StartView()
//            WordSuggestionView(koreanWord: "초대하다")
        }
    }
}
