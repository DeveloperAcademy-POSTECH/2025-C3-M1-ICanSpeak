//
//  ConversationCard.swift
//  umm
//
//  Created by Youbin on 6/5/25.
//

import SwiftUI
import Foundation

struct MainView: View {
    let calendar = Calendar.current
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    @State private var weekOffset: Int = 0

    @State private var isSelecting = false
    @State private var hasSelection = false
    @State private var selectedSessionIDs: Set<UUID> = []

    @StateObject private var messageReceiver = PhoneSessionManager.shared
    @AppStorage("_isFirstLaunching") var isFirstOnboarding: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                BackgorounView()

                VStack(spacing: 15) {
                    CalendarView(
                        calendar: calendar,
                        selectedDate: $selectedDate,
                        showDatePicker: $showDatePicker,
                        weekOffset: $weekOffset,
                        isSelectionMode: $isSelecting,
                        hasSelection: $hasSelection,
                        onDeleteSelected: deleteSelectedSessions
                    )

                    ScrollView {
                        VStack(spacing: 24) {
                            if filteredSessions.isEmpty {
                                NoDataView(
                                    text1: "아직 저장된 단어가 없어요.",
                                    text2: "AI와 대화하며 워치에게 단어를 물어보세요"
                                )
                                .padding(.top, 200)
                            } else {
                                ForEach(filteredSessions) { session in
                                    sessionCardRow(for: session)
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .scrollIndicators(.hidden)
                }

                if showDatePicker {
                    ZStack {
                        Color.white.opacity(0.01)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showDatePicker = false
                            }

                        VStack {
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                                .padding()
                        }
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

    private func deleteSelectedSessions() {
        messageReceiver.conversationSessions.removeAll {
            selectedSessionIDs.contains($0.id)
        }
        selectedSessionIDs.removeAll()
        hasSelection = false
        isSelecting = false
    }

    private func toggleSessionSelection(_ id: UUID) {
        if selectedSessionIDs.contains(id) {
            selectedSessionIDs.remove(id)
        } else {
            selectedSessionIDs.insert(id)
        }
        hasSelection = !selectedSessionIDs.isEmpty
    }

    @ViewBuilder
    private func sessionCardRow(for session: ConversationSession) -> some View {
        if isSelecting {
            ConversationCard(
                session: session,
                isSelecting: true,
                isSelected: selectedSessionIDs.contains(session.id),
                toggleSelection: {
                    toggleSessionSelection(session.id)
                }
            )
            .onTapGesture {
                toggleSessionSelection(session.id)
            }
        } else {
            NavigationLink(
                destination: ConversationDetailView(sessionId: session.id),
                label: {
                    ConversationCard(
                        session: session,
                        isSelecting: false,
                        isSelected: false,
                        toggleSelection: {}
                    )
                }
            )
            .buttonStyle(.plain)
        }
    }
}

//#Preview {
//    MainView()
//}
