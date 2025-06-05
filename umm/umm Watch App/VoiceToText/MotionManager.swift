//
//  MotionRecorder.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import Foundation
import CoreMotion
import AVFoundation

/// 기울기(모션) 감지와 녹음을 같이 관리하는 매니저
class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    /// 모션 업데이트용 CMMotionManager
    private let motionManager = CMMotionManager()
    
    /// 녹음 파일 URL
    var recordedFileURL: URL?
    private var audioRecorder: AVAudioRecorder?
    
    @Published var isHandRaised: Bool = false      // 손 들림 여부
    @Published var isRecording: Bool = false       // 현재 녹음 중인지
    @Published var isSpeaking: Bool = false        // 소음 유무
    @Published var didFinishRecording: Bool = false // 녹음 종료 신호
    
    private var silenceTimer: Timer?
    private var silenceCount: Int = 0
    
    /// Pause 상태를 전달받을 매니저
    var pauseManager: PauseManager?
    
    private init() {
        requestPermissionOnce()
        configureAudioSession()
        prepareRecorder()
    }
    
    private func requestPermissionOnce() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                print("❌ 마이크 권한이 거부되었습니다.")
            }
        }
    }
    
    /// AVAudioSession 설정
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            print("✅ 오디오 세션 설정 완료")
        } catch {
            print("❌ 오디오 세션 설정 실패: \(error.localizedDescription)")
        }
    }
    
    /// AVAudioRecorder를 미리 준비해 두어서 인스턴스 재사용
    private func prepareRecorder() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let fileName = FileManager.default.temporaryDirectory.appendingPathComponent("motion_record.m4a")
        recordedFileURL = fileName
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            print("녹음기 준비 완료")
        } catch {
            print("녹음기 준비 실패: \(error.localizedDescription)")
        }
    }
    
    /// 모션 감지 시작 (손 들렸는지 판별 → 녹음 시작/중단)
    func startMonitoring() {
        configureAudioSession()
        prepareRecorder()
        
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            guard let pauseManager = self.pauseManager else { return }
            
            // 일시정지 상태면 모션 콜백 자체를 무시
            if pauseManager.isPaused {
                print("🚫 모션 감지 무시됨 (일시정지 중)")
                return
            }
            
            guard let attitude = motion?.attitude else { return }
            let pitch = attitude.pitch * 180 / .pi
            print("pitch: \(pitch)")
            
            // 손 들어올린 순간
            if !self.isHandRaised && pitch > 50 {
                self.isHandRaised = true
                print("손 들었음")
                self.startRecording()
            }
            // 손 내려간 순간
            else if self.isHandRaised && pitch < 10 {
                self.isHandRaised = false
                print("손 내림")
                self.stopRecording()
            }
        }
    }
    
    /// 녹음 시작
   func startRecording() {
        guard let pauseManager = pauseManager, !pauseManager.isPaused else {
            print("🚫 녹음 시작 무시됨 (일시정지 중)")
            return
        }
        guard let recorder = audioRecorder else { return }
        
        if !recorder.isRecording {
            recorder.prepareToRecord()
            recorder.record()
            isRecording = true
            print("▶️ 녹음 시작됨")
            
            // 무음 체크 타이머
            silenceCount = 0
            silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                
                // 타이머 내부에서도 일시정지 상태면 무시
                guard let pm = self.pauseManager, !pm.isPaused else {
                    print("🚫 녹음 모니터링 무시됨 (일시정지 중)")
                    return
                }
                
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
    
    /// 녹음 종료 (파일 전송 및 상태 초기화)
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        silenceTimer?.invalidate()
        silenceTimer = nil
        isSpeaking = false
        print("⏹️ 녹음 종료")
        
        if let url = recordedFileURL {
            WatchSessionManager.shared.sendAudioFile(url: url)
        }
        
        DispatchQueue.main.async {
            self.didFinishRecording = true
        }
    }
    
    /// 일시정지 시 호출: 모션·녹음 모두 완전 중단
    func pauseRecording() {
        print("⏸️ 녹음 일시정지 → 모든 상태 초기화")
        
        // 1) CMMotionManager 업데이트 중단
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        
        // 2) 녹음 중이면 중단
        if let recorder = audioRecorder, recorder.isRecording {
            recorder.stop()
        }
        
        // 3) 타이머 중단
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        // 4) 상태 초기화
        isRecording = false
        isHandRaised = false
        isSpeaking = false
        silenceCount = 0
        
        // 5) AVAudioSession 비활성화해서 마이크 꺼짐 표시
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("✅ 오디오 세션 비활성화됨")
        } catch {
            print("❌ 오디오 세션 비활성화 실패: \(error)")
        }
    }
    
    /// 재개 시 호출: 녹음 관련 초기화만 해 두고, 실제 녹음은 startMonitoring() → startRecording() 흐름으로
    func resumeRecording() {
        print("▶️ 녹음 재개 준비")
        configureAudioSession()
        prepareRecorder()
    }
    
    /// 완전 종료 시 호출: 모션·녹음 모두 끄기
    func stopMonitoring() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        isHandRaised = false
        
        if let recorder = audioRecorder, recorder.isRecording {
            recorder.stop()
        }
        isRecording = false
        
        silenceTimer?.invalidate()
        silenceTimer = nil
        isSpeaking = false
        
        // 오디오 세션 비활성화
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("✅ 오디오 세션 완전 비활성화됨")
        } catch {
            print("❌ 오디오 세션 비활성화 실패: \(error)")
        }
        
        print("📴 모션 감지 중지됨")
    }
}
