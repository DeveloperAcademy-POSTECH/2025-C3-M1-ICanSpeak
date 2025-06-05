import SwiftUI
import Foundation

struct MainView: View {
  init() {
    UIDatePicker.appearance().tintColor = UIColor.orange
  }
  let calendar = Calendar.current
  @State private var selectedDate: Date = Date()
  @State private var showDatePicker = false
  @State private var weekOffset: Int = 0
  
  // MARK: - 선택된 주의 날짜 배열 생성
  var body: some View {
    
    let week: [Date] = {
      let startOfTargetWeek = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: Calendar.current.startOfWeek(for: selectedDate))!
      return (0..<7).compactMap {
        Calendar.current.date(byAdding: .day, value: $0, to: startOfTargetWeek)
      }
    }()
    
    // MARK: - 메인 UI
    ZStack {
      Color(red: 1.0, green: 0.95, blue: 0.9).ignoresSafeArea()
      
      VStack(spacing: 8) {
        // 상단: 현재 월 표시 및 달력 버튼
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
        
        // 요일 및 날짜 표시 영역
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
        
        
      Spacer()
        
      }
    }
    // MARK: - 팝업 달력 (DatePicker)
    .overlay(
      Group {
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
                  .fill(Color.orange.opacity(0.1))
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

// MARK: - 시작 요일 계산, 월 포맷터
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
