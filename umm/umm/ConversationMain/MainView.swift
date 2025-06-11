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
        NavigationStack {
            ZStack {
                BackgorounView()
                
                VStack(spacing: 15, content: {
                    CalendarView(
                        calendar: calendar,
                        selectedDate: $selectedDate,
                        showDatePicker: $showDatePicker,
                        weekOffset: $weekOffset
                    )
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(filteredSessions) { session in
                                NavigationLink(destination: ConversationDetailView(session: session)) {
                                    ConversationCard(session: session)
                                }
                            }
                        }
                        .padding(.top, 0)
                        .padding(.horizontal, 15)
                    }
                    .scrollIndicators(.hidden)
                })
                
                if showDatePicker {
                    ZStack {
                        Color.white.opacity(0.01)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showDatePicker = false
                            }

                        VStack {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                            .padding()
                        }
                        .transition(.opacity)
                    }
                }
            }
            .fullScreenCover(isPresented: $isFirstOnboarding) {
                OnboardingTabView(isFirstOnboarding: $isFirstOnboarding)
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
