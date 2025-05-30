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
    
    // MARK: - Initialization
//    override init() {
//        super.init()
//        setup() // 무조건 실행되도록
//    }
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
        guard let model = try? ummsound(configuration: MLModelConfiguration()) else {
            print("❌ 모델 로딩 실패")
            return
        }

        do {
            let request = try SNClassifySoundRequest(mlModel: model.model)
            self.request = request
            request.windowDuration = CMTimeMakeWithSeconds(0.975, preferredTimescale: 1000)
            request.overlapFactor = 0.75
        } catch {
            print("❌ 요청 생성 실패: \(error)")
            return
        }

        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)

        do {
            try streamAnalyzer.add(self.request!, withObserver: self)
        } catch {
            print("❌ 분석기 추가 실패: \(error)")
        }

        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { buffer, time in
            self.analysisQueue.async {
                self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }

        startAudioEngine()
    }
    
    // MARK: - Audio Engine Control
    private func startAudioEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            print("✅ 오디오 엔진 시작")
        } catch {
            print("❌ 오디오 세션 시작 실패: \(error)")
        }
    }
    
    // MARK: - SNResultsObserving
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }

        if let classification = classificationResult.classifications.first {
            DispatchQueue.main.async {
                let label = classification.identifier
                print("🔊 감지된 소리: \(label)")

                // "Um"일 때만 즉시 햅틱 울림
                if label == "Um" {
                    print("🔥 햅틱 실행됨 - 감지된 소리: \(label)")
                    self.detectedSound = "감지됨: \(label)"
                    WKInterfaceDevice.current().play(.success)
                }
                // "etc" 처리
                else if label == "etc" {
                    if self.lastLabel == "etc" {
                        if let start = self.etcStartTime {
                            let timePassed = Date().timeIntervalSince(start)
                            if timePassed >= 3 {
                                print("🔥 햅틱 실행됨 - 3초 이상 기타 소리 감지")
                                self.detectedSound = "3초 이상 기타 소리 감지됨"
                                WKInterfaceDevice.current().play(.success)
                                //etc소리 3초 이상 연속 감지 후 초기화
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
                // 나머지 소리는 햅틱 없이 표시만
                else {
                    self.etcStartTime = nil
                    self.detectedSound = "다른 소리: \(label)"
                }
                
                self.lastLabel = label
            }
        }
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ 요청 실패: \(error)")
    }

    func requestDidComplete(_ request: SNRequest) {
        print("✅ 분석 완료")
    }
}
