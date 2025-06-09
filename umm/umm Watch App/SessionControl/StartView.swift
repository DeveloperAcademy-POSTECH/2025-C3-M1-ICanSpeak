import SwiftUI
import WatchConnectivity

struct StartView: View {
    @State private var isActive = false
  
    var body: some View {
        Group {
            if isActive {
                MainTabView()
            } else {
                Button(action: {
                    isActive = true
                    let startTime = Date()
                    WatchSessionManager.shared.sendStartTimeToApp(date: startTime)
                }, label: {
                    ZStack {
                        Circle()
                            .fill(Color.ummPrimary)
                            .frame(width: 134, height: 134)
                        Text("Start")
                            .font(.sfbold20)
                            .foregroundColor(.white)
                    }
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didRequestAppReset)) { _ in
            isActive = false
        }
    }
}

  
  #Preview {
    StartView()
  }


