import SwiftUI
import WatchConnectivity

struct StartView: View {
    var body: some View {
  @State private var isStarted = false
  @State private var tabSelection = 1
  
  
  var body: some View {
    if isStarted {
      TabView(selection: $tabSelection) {
        PauseView(soundDetector: SoundDetector(), gestureDetector: GestureDetector(), onExit: {
          isStarted = false
        })
          .tag(0)
        MainView()
          .tag(1)
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .onAppear {
        tabSelection = 1
      }
    } else {
      Button(action: {
        let startTime = Date()
        WatchSessionManager.shared.sendStartTimeToApp(date: startTime)
        isStarted = true
      }) {
        ZStack {
          Circle()
            .fill(Color.ummPrimary)
            .frame(width: 134, height: 134)
          Text("Start")
            .font(.sfbold20)
            .foregroundColor(.white)
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}

#Preview {
    StartView()
}
