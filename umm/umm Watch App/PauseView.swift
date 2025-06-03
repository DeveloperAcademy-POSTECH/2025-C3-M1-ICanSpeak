//
//  PauseView.swift
//  umm Watch App
//
//  Created by 강진 on 5/28/25.
//

import SwiftUI
import WatchConnectivity

struct PauseView: View {
    @ObservedObject var soundDetector = SoundDetectionManager()
    @ObservedObject var gestureDetector = MotionManager()
    @State private var isPaused: Bool = false
    var onExit: () -> Void

    var body: some View {
      
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
                        onExit()
                        gestureDetector.stopRecording()
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
                            soundDetector.stopDetection()
                            gestureDetector.stopRecording()
                            //TODO: 제스처 스탑 리코딩
                        } else {
                          soundDetector.startDetection()
                          gestureDetector.stopRecording()
                          gestureDetector.startMonitoring()
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

