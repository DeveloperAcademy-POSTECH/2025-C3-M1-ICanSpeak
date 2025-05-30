import SwiftUI

struct StartView: View {
    @State private var isStarted = false
    @StateObject private var soundDetector = SoundDetector()
    @StateObject private var gestureDetector = GestureDetector()

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(
                    destination: AnimationView(soundDetector: soundDetector, gestureDetector: gestureDetector),
                    isActive: $isStarted
                ) {
                    Button(action: {
                        isStarted = true
                        soundDetector.startListening()
                        gestureDetector.startDetecting()
                    }) {
                        Text("Start")
                            .font(Font.custom("SF Compact", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 134, height: 134)
                            .background(
                                Circle()
                                    .fill(Color("Main Orange"))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

#Preview {
    StartView()
}
