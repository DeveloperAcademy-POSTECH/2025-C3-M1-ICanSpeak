//
//  Calendar.swift
//  umm
//
//  Created by 강진 on 6/5/25.
//

import SwiftUI

struct CalendarView: View {
    let calendar: Calendar
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    @Binding var weekOffset: Int
  
    init(calendar: Calendar, selectedDate: Binding<Date>, showDatePicker: Binding<Bool>, weekOffset: Binding<Int>) {
        self.calendar = calendar
        self._selectedDate = selectedDate
        self._showDatePicker = showDatePicker
        self._weekOffset = weekOffset
        UIDatePicker.appearance().tintColor = UIColor.orange
    }

    private var week: [Date] {
        let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfWeek(for: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        VStack(spacing: 8) {
            // 상단: 현재 월 표시 및 달력 버튼
            HStack {
                Spacer()
                Text(DateFormatter.customMonthFormatter.string(from: week.first ?? selectedDate))
                    .font(.montBold17)
                    .foregroundColor(.txt06)
                    .padding(.leading, 21)
                Spacer()
                Button(action: {
                    showDatePicker = true
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.txt06)
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
                            .foregroundColor(isSelected ? Color("txt-primary") : Color("txt06"))
                            .font(.sfregular12)
                        Text(date, format: .dateTime.day())
                            .foregroundColor(isSelected ? Color("txt-primary") : Color("txt06"))
                            .font(.montMedium17)
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
//        .overlay(
//            Group {
//                if showDatePicker {
//                    ZStack {
//                        Color.white.opacity(0.01)
//                            .ignoresSafeArea()
//                            .onTapGesture {
//                                showDatePicker = false
//                            }
//
//                        VStack {
//                            DatePicker(
//                                "",
//                                selection: $selectedDate,
//                                displayedComponents: [.date]
//                            )
//                            .datePickerStyle(.graphical)
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color("txt-primary").opacity(0.12))
//                            )
//                            .padding()
//                        }
//                    }
//                    .transition(.opacity)
//                }
//            }
//        )
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
