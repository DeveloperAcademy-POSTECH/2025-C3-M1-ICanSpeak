import SwiftUI
import Foundation

struct MainView: View {
  let calendar = Calendar.current
  @State private var selectedDate: Date = Date()
  @State private var showDatePicker = false
  @State var logs: [TimeLog] = []
  @ObservedObject var sessionManager = PhoneSessionManager.shared
  @State private var weekOffset: Int = 0
  
  var body: some View {
    
    let startOfTargetWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfWeek(for: selectedDate))!
    let week = (0..<7).compactMap {
      calendar.date(byAdding: .day, value: $0, to: startOfTargetWeek)
    }
    let filteredLogs = logs.filter {
      calendar.isDate($0.start, inSameDayAs: selectedDate)
    }

    VStack(spacing: 8) {
      HStack {
        Spacer()
        Text(DateFormatter.customMonthFormatter.string(from: week.first ?? selectedDate))
          .font(.system(size: 17))
        Spacer()
        Button(action: {
          showDatePicker = true
        }) {
          Image(systemName: "calendar")
            .foregroundColor(.orange)
        }
      }
      .padding(.horizontal)
      .padding(.top)
      
      HStack {
        ForEach(week, id: \.self) { date in
          let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
          VStack {
            Text(date, format: .dateTime.weekday())
              .foregroundColor(isSelected ? .orange : .gray)
              .font(.system(size:12))
            Text(date, format: .dateTime.day())
              .foregroundColor(isSelected ? .orange : .primary)
              .font(.system(size:17))
          }
          .frame(maxWidth: .infinity)
          .onTapGesture {
            selectedDate = date
            weekOffset = 0
          }
        }
      }
      .padding()
      .gesture(
        DragGesture().onEnded { value in
          if value.translation.width < -20 {
            weekOffset += 1
          } else if value.translation.width > 20 {
            weekOffset -= 1
          }
        }
      )
      
      VStack(alignment: .leading, spacing: 10) {
        ForEach(filteredLogs) { log in
          HStack(alignment: .center, spacing: 6) {
            Circle()
              .fill(Color.orange)
              .frame(width: 6, height: 6)
            if let exit = log.exit {
              Text("\(TimeLogManager.formatTime(log.start)) - \(TimeLogManager.formatTime(exit))")
                .font(.system(size: 12))
            } else {
              Text("\(TimeLogManager.formatTime(log.start)) - ...")
                .font(.system(size:12))
            }
            Spacer()
          }
        }
      }
    Spacer()
    .onAppear {
      logs = TimeLogManager.loadLogs()
    }
    .onChange(of: sessionManager.startTime) { _ in
      logs.append(TimeLog(start: Date(), exit: nil))
      TimeLogManager.saveLogs(logs)
    }
    .onChange(of: sessionManager.exitTime) { _ in
      if let lastIndex = logs.indices.last {
        logs[lastIndex].exit = Date()
        TimeLogManager.saveLogs(logs)
      }
    }
      
    }
    .overlay(
      Group {
        if showDatePicker {
          ZStack {
            Color.black.opacity(0.3)
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
                  .fill(Color(.systemBackground).opacity(0.9))
              )
              .padding()
            }
          }
          .transition(.opacity)
        }
      }
    )
  }
}

extension Calendar {
  func startOfWeek(for date: Date) -> Date {
    self.dateInterval(of: .weekOfYear, for: date)!.start
  }
}

extension DateFormatter {
  static let customMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM"
    return formatter
  }()
}

#Preview {
  MainView()
}
