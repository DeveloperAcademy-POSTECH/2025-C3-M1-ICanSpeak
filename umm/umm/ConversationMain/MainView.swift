import SwiftUI
import Foundation

struct MainView: View {
    let calendar = Calendar.current
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var weekOffset: Int = 0
    @StateObject private var messageReceiver = PhoneSessionManager.shared
    
    @AppStorage("_isFirstLaunching") var isFirstOnboarding: Bool = true
    
    var body: some View {
        NavigationStack{
            ZStack {
                BackgorounView()
                
                ScrollView {
                    VStack(spacing: 12) {
                            CalendarView(
                                calendar: calendar,
                                selectedDate: $selectedDate,
                                showDatePicker: $showDatePicker,
                                weekOffset: $weekOffset
                            )
                        
                        VStack(spacing: 24) {
                            ForEach(filteredSessions) { session in
                                NavigationLink(destination: ConversationDetailView(session: session)) {
                                    ConversationCard(session: session)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .fullScreenCover(isPresented: $isFirstOnboarding) {
                    OnboardingTabView(isFirstOnboarding: $isFirstOnboarding)
                }
            }

        }
    }
    
    private var filteredSessions: [ConversationSession] {
        messageReceiver.conversationSessions.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: selectedDate)
        }
    }
}

#Preview {
    MainView()
}
