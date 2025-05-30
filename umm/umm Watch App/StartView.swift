import SwiftUI

struct StartView: View {
    @State private var isStarted = false
    @State private var path: [String] = []
    @StateObject private var soundDetector = SoundDetector()
    @StateObject private var gestureDetector = GestureDetector()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button(action: {
                    path.append("FirstDetect")
                    soundDetector.startListening()
                    gestureDetector.startDetecting()
                }) {
                    Text("Start")
                        .font(Font.custom("SF Compact", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 134, height: 134)
                .background(
                    Circle()
                        .fill(Color("Main Orange"))
                )
                .clipShape(Circle())
            }
            .padding()
            .navigationDestination(for: String.self) { value in
                if value == "FirstDetect" {
                    FirstDetectView()
                }
            }
        }
    }
}

#Preview {
    StartView()
}
