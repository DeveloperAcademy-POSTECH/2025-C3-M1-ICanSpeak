//
//  SoundDetectionManager.swift
//  WatchTest29th Watch App
//
//  Created by MINJEONG on 5/29/25.
//

import Foundation
import AVFoundation
import SoundAnalysis
import CoreML
import WatchKit

class SoundDetectionManager: NSObject, ObservableObject, SNResultsObserving {

// MARK: - Properties
private let audioEngine = AVAudioEngine()
private var streamAnalyzer: SNAudioStreamAnalyzer!
private let analysisQueue = DispatchQueue(label: "SoundAnalysisQueue")
private var request: SNClassifySoundRequest?

@Published var detectedSound: String = ""
private var etcDuration: TimeInterval = 0
private var lastLabel: String = ""
private var etcStartTime: Date?

private var isSetupCompleted = false // ✅ setup 1회만 실행 체크용

// MARK: - Initialization
override init() {
    super.init()

    #if DEBUG
    if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
        setup()
    }
    #else
    setup()
    #endif
}

// MARK: - Setup
private func setup() {
    guard !isSetupCompleted else { return }  // ✅ 이미 세팅되었으면 중복 방지

    guard let model = try? umspeech(configuration: MLModelConfiguration()) else {
        print("❌ 모델 로딩 실패")
        return
    }

    do {
        let request = try SNClassifySoundRequest(mlModel: model.model)
        self.request = request
        request.windowDuration = CMTimeMakeWithSeconds(0.975, preferredTimescale: 1000)
        request.overlapFactor = 0.75
    } catch {
        print("❌ 요청 생성 실패: \\(error)")
        return
    }

    let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
    streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

    do {
        try streamAnalyzer.add(self.request!, withObserver: self)
    } catch {
        print("❌ 분석기 추가 실패: \\(error)")
    }

    audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { buffer, time in
        self.analysisQueue.async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }

    isSetupCompleted = true  // ✅ 세팅 완료 표시
    print("✅ 초기 세팅 완료")
}

// MARK: - 감지 시작
func startDetection() {
    if !audioEngine.isRunning {
        setup()  // 혹시 setup() 안 됐을 경우를 대비해서 안전장치
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            print("🎙️ 감지 시작됨")
        } catch {
            print("❌ 감지 시작 실패: \\(error)")
        }
    }
}

// MARK: - 감지 중지
func stopDetection() {
    if audioEngine.isRunning {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        print("🛑 감지 중지됨")
    }
}

// MARK: - SNResultsObserving
func request(_ request: SNRequest, didProduce result: SNResult) {
    guard let classificationResult = result as? SNClassificationResult else { return }

    if let classification = classificationResult.classifications.first {
        DispatchQueue.main.async {
            let label = classification.identifier
            print("🔊 감지된 소리: \\(label)")

            if label == "Um" {
                print("🔥 햅틱 실행됨 - 감지된 소리: \\(label)")
                self.detectedSound = "감지됨: \\(label)"
                WKInterfaceDevice.current().play(.success)
            }
            else if label == "etc" {
                if self.lastLabel == "etc" {
                    if let start = self.etcStartTime {
                        let timePassed = Date().timeIntervalSince(start)
                        if timePassed >= 3 {
                            print("🔥 햅틱 실행됨 - 3초 이상 기타 소리 감지")
                            self.detectedSound = "3초 이상 기타 소리 감지됨"
                            WKInterfaceDevice.current().play(.success)
                            self.etcStartTime = nil
                        } else {
                            self.detectedSound = "기타 소리 감지 중..."
                        }
                    }
                } else {
                    self.etcStartTime = Date()
                    self.detectedSound = "기타 소리 감지 중..."
                }
            }
            else {
                self.etcStartTime = nil
                self.detectedSound = "다른 소리: \\(label)"
            }

            self.lastLabel = label
        }
    }
}

func request(_ request: SNRequest, didFailWithError error: Error) {
    print("❌ 요청 실패: \\(error)")
}

func requestDidComplete(_ request: SNRequest) {
    print("✅ 분석 완료")
}

}
