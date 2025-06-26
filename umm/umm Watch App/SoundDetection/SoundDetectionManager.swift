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

/// 소리(음성) 감지를 담당하는 매니저
class SoundDetectionManager: NSObject, ObservableObject, SNResultsObserving {
    
    // MARK: - Properties
    static let shared = SoundDetectionManager()
    
    private let audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer!
    private let analysisQueue = DispatchQueue(label: "SoundAnalysisQueue")
    private var request: SNClassifySoundRequest?
    
    @Published var detectedSound: String = ""
    
    private var etcDuration: TimeInterval = 0
    private var lastLabel: String = ""
    private var etcStartTime: Date?
    
    private var isSetupCompleted = false
    var pauseManager: PauseManager?
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        guard !isSetupCompleted else { return }
        
        guard let model = try? umspeech(configuration: MLModelConfiguration()) else {
            print("❌ 모델 로딩 실패")
            return
        }
        
        do {
            let req = try SNClassifySoundRequest(mlModel: model.model)
            request = req
            req.windowDuration = CMTimeMakeWithSeconds(0.975, preferredTimescale: 1000)
            req.overlapFactor = 0.75
        } catch {
            print("❌ 요청 생성 실패: \(error)")
            return
        }
        
        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        do {
            try streamAnalyzer.add(request!, withObserver: self)
        } catch {
            print("❌ 분석기 추가 실패: \(error)")
        }
        
        isSetupCompleted = true
        print("✅ SoundDetection 초기 설정 완료")
    }
    
    //MARK: 감지 시작
    func startDetection() {
        guard pauseManager?.isPaused != true else {
            print("🚫 감지 시작 무시됨 (일시정지 중)")
            return
        }
        
        if !audioEngine.isRunning {
            setup()
            
            let inputNode = audioEngine.inputNode
            inputNode.removeTap(onBus: 0)
            
            let inputFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { buffer, time in
                self.analysisQueue.async {
                    guard self.pauseManager?.isPaused != true else {
                        return
                    }
                    self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                try audioEngine.start()
                print("▶️ 소리 감지 시작됨")
            } catch {
                print("❌ 소리 감지 시작 실패: \(error)")
            }
        }
    }
    
    // MARK: - 감지 중지 (일반 중지)
    func stopDetection() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            print("🛑 소리 감지 중지됨")
            
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                print("✅ 오디오 세션 비활성화됨 (일반 중지)")
            } catch {
                print("❌ 오디오 세션 비활성화 실패: \(error)")
            }
        }
    }
    
    // MARK: - ✅ 일시정지
    func pauseDetection() {
        print("⏸️ 소리 감지 일시정지")
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            print("✅ 오디오 엔진 중지됨")
        }
        
        // 상태 초기화
        detectedSound = ""
        lastLabel = ""
        etcStartTime = nil
    }
    
    // MARK: 감지 재개
    func resumeDetection() {
        print("▶️ 소리 감지 재개")
        startDetection()
    }
    
    // MARK: - SNResultsObserving
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        if let classification = classificationResult.classifications.first {
            DispatchQueue.main.async {
                if self.pauseManager?.isPaused == true {
                    print("🚫 감지 무시됨 (일시정지 중)")
                    return
                }
                
                let label = classification.identifier
                print("🔊 감지된 소리: \(label)")
                
                if label == "Um" {
                    print("🔥 햅틱 실행됨 - 감지된 소리: \(label)")
                    self.detectedSound = "감지됨: \(label)"
                    WKInterfaceDevice.current().play(.success)
                } else if label == "etc" {
                    if self.lastLabel == "etc" {
                        if let start = self.etcStartTime {
                            let timePassed = Date().timeIntervalSince(start)
                            if timePassed >= 5 {
                                print("🔥 햅틱 실행됨 - 5초 이상 기타 소리 감지")
                                self.detectedSound = "5초 이상 기타 소리 감지됨"
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
                } else {
                    self.etcStartTime = nil
                    self.detectedSound = "다른 소리: \(label)"
                }
                
                self.lastLabel = label
            }
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ 소리 감지 요청 실패: \(error)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("✅ 소리 분석 완료")
    }
}
