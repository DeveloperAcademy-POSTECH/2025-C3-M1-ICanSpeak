//
//  ummApp.swift
//  umm
//
//  Created by Youbin on 5/27/25.
//

import SwiftUI

@main
struct ummApp: App {
    init() {
        print("🧪 앱 시작 - PhoneSessionManager 초기화")
        _ = PhoneSessionManager.shared // ✅ 여기서 초기화 발생
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
