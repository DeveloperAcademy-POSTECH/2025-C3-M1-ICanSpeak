//
//  MotionRecorder.swift
//  Plz Watch App
//
//  Created by Ella's Mac on 5/29/25.
//

import Foundation
import AVFoundation

class MotionManager: ObservableObject {
    static let shared = MotionManager()

    @Published var isRecording: Bool = false
    var recordedFileURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var silenceTimer: Timer?
    private var silenceCount: Int = 0

    func requestPermissionOnce() {
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                print("❌ 마이크 권한이 거부되었습니다.")
            }
        }
    }

    init() {
        requestPermissionOnce()
        configureAudioSession()
        prepareRecorder()
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

    func prepareRecorder() {
        let fileName = UUID().uuidString + ".m4a"
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        recordedFileURL = filePath

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            print("🎙️ 오디오 레코더 준비 완료")
        } catch {
            print("❌ 오디오 레코더 준비 실패: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        prepareRecorder()
        audioRecorder?.record()
        isRecording = true
        print("🎙️ 녹음 시작")
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("🛑 녹음 종료")

        if let url = recordedFileURL {
            WatchSessionManager.shared.sendAudioFile(url: url)
        }
    }

    func pauseRecording() {
        audioRecorder?.pause()
        isRecording = false
        print("⏸ 녹음 일시정지")
    }

    func resumeRecording() {
        audioRecorder?.record()
        isRecording = true
        print("▶️ 녹음 재개")
    }
}
