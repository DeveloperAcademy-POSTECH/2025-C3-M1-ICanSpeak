//
//  PauseView.swift
//  umm Watch App
//
//  Created by 강진 on 5/28/25.
//

import SwiftUI
import WatchConnectivity

struct PauseView: View {
    @ObservedObject var soundDetector: SoundDetector
    @ObservedObject var gestureDetector: GestureDetector
    @State private var isPaused: Bool = false
    @State private var isExited = false

    var body: some View {
      
      if isExited {
        StartView()
      }
      else{
      VStack(spacing: 0) {
                  // 상단 우측 "Umm.." 파란 텍스트
                  HStack {
                      Spacer()
                      Text("Umm..")
                          .foregroundColor(.blue)
                          .font(.system(size: 18))
                          .fontWeight(.semibold)
                          .padding([.top, .trailing], 8)
                  }

                  Spacer()
            HStack(spacing: 10) {
                // 종료 버튼
                VStack(spacing: 5) {
                    Button(action: {
                        let exitTime = Date()
                        WatchSessionManager.shared.sendExitTimeToApp(date: exitTime)
                        isExited = true
                    }) {
                        Image(systemName: "xmark")
                        .font(.system(size: 23))
                        .fontWeight(.semibold)
                          .foregroundColor(.red)
                    }
                    .foregroundColor(.red)
                    .frame(width: 73, height: 50)
                    .cornerRadius(43)
                    Text("종료")
                        .foregroundColor(.white)
                        .font(.sdregular12)
                }

                // 일시정지 / 재개 버튼
                VStack(spacing: 5) {
                    Button(action: {
                        isPaused.toggle()
                        if isPaused {
                            soundDetector.stopListening()
                            gestureDetector.stopDetecting()
                        } else {
                            soundDetector.startListening()
                            gestureDetector.startDetecting()
                        }
                    }) {
                        Image(systemName: isPaused ? "arrow.clockwise" : "pause")
                            .font(.system(size: 23))
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                    .foregroundColor(.yellow)
                    .frame(width: 73, height: 50)
                    .cornerRadius(43)
                    Text(isPaused ? "재개" : "일시 정지")
                        .foregroundColor(.white)
                        .font(.sdregular12)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        }
    }
  
}

#Preview {
    PauseView(soundDetector: SoundDetector(), gestureDetector: GestureDetector())
}
