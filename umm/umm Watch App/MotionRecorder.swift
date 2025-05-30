//
//  MotionRecorder.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import Foundation
import CoreMotion
import AVFoundation

class MotionManager: ObservableObject {
    var recordedFileURL: URL?
//    @Published var isHandRaised = false
    let motionManager = CMMotionManager()
    var audioRecorder: AVAudioRecorder?
    var isRecording = false
    @Published var isSpeaking = false
    var silenceTimer: Timer?
    var silenceCount: Int = 0
    
    
    // 워치 기울기 실시간 감지하는 함수
    func startMonitoring() {
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let attitude = motion?.attitude else { return }
            let pitch = attitude.pitch * 180 / .pi
            print("pitch: \(pitch)")
            
            if pitch > 50 {
                print("손 들었음")
                if !self.isRecording {
                        self.startRecording()
                    }
                
            } else {
                print("손 내림")
                if self.isRecording {
                       self.stopRecording()
                   }
            }
        }
    }
    
    func startRecording() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.actuallyStartRecording()
                } else {
                    print("❌ 마이크 권한이 거부되었습니다.")
                }
            }
        }
    }

        private func actuallyStartRecording() {
        // 1. 녹음 설정
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
       // 2. 녹음 파일 저장 위치
        let fileName = FileManager.default.temporaryDirectory
            .appendingPathComponent("record.m4a")
            
        recordedFileURL = fileName
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.isMeteringEnabled = true  // 데시벨 측정 켜기
            audioRecorder?.record()
            isRecording = true
            print("녹음 시작됨")
            
            silenceCount = 0
            silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                print("소리크기: \(power)")
                
                if power < -50 {
                    self.isSpeaking = false
                    self.silenceCount += 1
                    print("조용 카운트: \(self.silenceCount)")
                    if self.silenceCount >= 3 {
                        self.stopRecording()
                    }
                } else {
                    self.isSpeaking = true
                    self.silenceCount = 0
                }
            }
        } catch {
            print("녹음 실패: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        silenceTimer?.invalidate()
        silenceTimer = nil
        print("녹음 종료")
        
        if let fileURL = recordedFileURL {
            WatchSessionManager.shared.sendAudioFile(url: fileURL)
        }
    }
}
