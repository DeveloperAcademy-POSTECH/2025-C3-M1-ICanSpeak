//
//  PauseView.swift
//  umm Watch App
//
//  Created by 강진 on 5/28/25.
//

import SwiftUI
import WatchConnectivity

struct PauseView: View {
    @EnvironmentObject var pauseManager: PauseManager // 추가
    @EnvironmentObject var soundManager: SoundDetectionManager
    @EnvironmentObject var motionManager: MotionManager
    
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
                
            HStack(spacing: 8, content: {
                //종료 버튼
                VStack(spacing: 4, content: {
                    Button(action: {
                        let exitTime = Date()
                        WatchSessionManager.shared.sendExitTimeToApp(date: exitTime)
                        motionManager.stopMonitoring()
                        soundManager.stopDetection()
                        NotificationCenter.default.post(name: .didRequestAppReset, object: nil)
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 23))
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    })
                    .foregroundColor(.red)
                    .frame(width: 73, height: 50)
                    .cornerRadius(43)
                    
                    Text("종료")
                        .foregroundColor(.white)
                        .font(.sdregular12)
                })
                
                //일시정지, 재개 버튼
                VStack(spacing: 4, content: {
                    Button(action: {
                        pauseManager.isPaused.toggle()
                    }, label: {
                        Image(systemName: pauseManager.isPaused ? "arrow.clockwise" : "pause")
                            .font(.system(size: 23))
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    })
                    .foregroundColor(.yellow)
                    .frame(width: 73, height: 50)
                    .cornerRadius(43)
                    
                    Text(pauseManager.isPaused ? "재개" : "일시 정지")
                        .foregroundColor(.white)
                        .font(.sdregular12)
                })
            })
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

