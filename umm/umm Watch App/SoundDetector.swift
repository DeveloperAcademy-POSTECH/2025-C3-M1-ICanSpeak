import Foundation
import SoundAnalysis
import AVFoundation
import CoreML
import WatchKit

class SoundDetector: NSObject, ObservableObject, SNResultsObserving {
    private var analyzer: SNAudioStreamAnalyzer?
    private let audioEngine = AVAudioEngine()
    private var request: SNClassifySoundRequest?

    func startListening() {
        guard let modelURL = Bundle.main.url(forResource: "sound", withExtension: "mlmodelc"),
              let model = try? MLModel(contentsOf: modelURL) else {
            print("Model not found or failed to load")
            return
        }

        do {
            let snModel = try SNClassifySoundRequest(mlModel: model)
            request = snModel
            let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            analyzer = SNAudioStreamAnalyzer(format: inputFormat)
            try audioEngine.start()

          try analyzer?.add(snModel, withObserver: self)

            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
                self.analyzer?.analyze(buffer, atAudioFramePosition: AVAudioFramePosition(Date().timeIntervalSince1970))
            }
        } catch {
            print("Failed to start sound analysis: \(error)")
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        analyzer = nil
        request = nil
    }

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classification = result as? SNClassificationResult,
              let topResult = classification.classifications.first else { return }

        DispatchQueue.main.async {
            WKInterfaceDevice.current().play(.notification)
        }
    }
}
