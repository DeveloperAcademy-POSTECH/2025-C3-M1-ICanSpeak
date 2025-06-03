//
//  ummApp.swift
//  umm
//
//  Created by Youbin on 5/27/25.
//

import SwiftUI

@main
struct ummApp: App {
    var body: some Scene {
        WindowGroup {
            TimeLogView()
                .onAppear {
                    let _ = PhoneSessionManager.shared
                }
        }
    }
}
