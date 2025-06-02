import SwiftUI

struct StartView: View {
    @State private var isStarted = false
    @StateObject private var soundDetector = SoundDetector()
    @StateObject private var gestureDetector = GestureDetector()

    var body: some View {
            VStack {
              if isStarted {
                FirstDetectView()
              } else {
                Button(action: {
                  isStarted = true
                    soundDetector.startListening()
                    gestureDetector.startDetecting()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("Main Orange"))
                            .frame(width: 134, height: 134)
                        Text("Start")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            }
        }
    }

#Preview {
    StartView()
}
