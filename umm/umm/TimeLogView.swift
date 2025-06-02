//
//  TimeLogView.swift
//  umm
//
//  Created by 강진 on 6/2/25.
//

import SwiftUI

struct TimeLogView: View {
    @ObservedObject var sessionManager = PhoneSessionManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("⌚️ 워치에서 수신된 시간")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("▶️ Start Time:")
                        .bold()
                    Spacer()
                    Text(sessionManager.startTime.isEmpty ? "없음" : sessionManager.startTime)
                        .foregroundColor(.blue)
                }

                HStack {
                    Text("⏹ Exit Time:")
                        .bold()
                    Spacer()
                    Text(sessionManager.exitTime.isEmpty ? "없음" : sessionManager.exitTime)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .padding()
    }
}

#Preview {
    TimeLogView()
}
