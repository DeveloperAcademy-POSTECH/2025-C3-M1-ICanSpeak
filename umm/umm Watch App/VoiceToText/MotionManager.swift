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
    static let shared = MotionManager()
    
    var recordedFileURL: URL?
    @Published var isHandRaised = false
    let motionManager = CMMotionManager()
    var audioRecorder: AVAudioRecorder?
    var isRecording = false
    @Published var isSpeaking = false
    @Published var didFinishRecording = false
    var silenceTimer: Timer?
    var silenceCount: Int = 0

    init() {
        requestPermissionOnce()
        configureAudioSession()
        prepareRecorder()  // ✅ AVAudioRecorder 미리 준비
    }

    func requestPermissionOnce() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                print("❌ 마이크 권한이 거부되었습니다.")
            }
        }
    }

    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            print("✅ 오디오 세션 설정 완료")
        } catch {
            print("❌ 오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }

    // ✅ AVAudioRecorder 미리 준비 → 인스턴스 재사용
    private func prepareRecorder() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let fileName = FileManager.default.temporaryDirectory.appendingPathComponent("record.m4a")
        recordedFileURL = fileName

        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            print("녹음기 준비 완료")
        } catch {
            print("녹음기 준비 실패: \(error.localizedDescription)")
        }
    }

    func startMonitoring() {
        configureAudioSession()
        prepareRecorder()
        
        if motionManager.isDeviceMotionActive {
            print("🔁 기존 감지 중지 후 재시작")
            motionManager.stopDeviceMotionUpdates()
        }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let attitude = motion?.attitude else { return }
            let pitch = attitude.pitch * 180 / .pi
            print("pitch: \(pitch)")
            
            if !self.isHandRaised && pitch > 50 {
                self.isHandRaised = true
                print("손 들었음")
                self.startRecording()
            }

            if self.isHandRaised && pitch < 10 {
                self.isHandRaised = false
                print("손 내림")
                self.stopRecording()
            }
        }
    }

    func startRecording() {
        guard let recorder = audioRecorder else { return }

        if !recorder.isRecording {
            recorder.prepareToRecord()
            recorder.record()
            isRecording = true
            print("녹음 시작됨")

            silenceCount = 0
            silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                let power = recorder.averagePower(forChannel: 0)
                print("소리크기: \(power)")

                if power < -40 {
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
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        silenceTimer?.invalidate()
        silenceTimer = nil
        print("녹음 종료")

        if let fileURL = recordedFileURL {
            WatchSessionManager.shared.sendAudioFile(url: fileURL)
        }
        
        // ✅ 종료 신호 보냄
        DispatchQueue.main.async {
            self.didFinishRecording = true
        }
    }
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isHandRaised = false
        stopRecording()
        print("📴 모션 감지 중지됨")
    }
}
