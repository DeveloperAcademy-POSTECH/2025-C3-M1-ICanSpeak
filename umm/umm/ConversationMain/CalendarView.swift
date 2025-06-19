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
    @Binding var isSelectionMode: Bool
    @Binding var hasSelection: Bool
    var onDeleteSelected: (() -> Void)?
  
    init(calendar: Calendar, selectedDate: Binding<Date>, showDatePicker: Binding<Bool>, weekOffset: Binding<Int>, isSelectionMode: Binding<Bool>, hasSelection: Binding<Bool>, onDeleteSelected: (() -> Void)? = nil) {
        self.calendar = calendar
        self._selectedDate = selectedDate
        self._showDatePicker = showDatePicker
        self._weekOffset = weekOffset
        self._isSelectionMode = isSelectionMode
        self._hasSelection = hasSelection
        self.onDeleteSelected = onDeleteSelected
        UIDatePicker.appearance().tintColor = UIColor.orange
        UIPageControl.appearance().isHidden = true
    }

    private var weeks: [[Date]] {
        let range = -2...2
        return range.map { offset in
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: offset + weekOffset, to: calendar.startOfWeek(for: selectedDate))!
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // 상단: 현재 월 표시 및 달력 버튼
            HStack {
                Button(action: {
                    showDatePicker = true
                }) {
                    Image(systemName: "calendar")
                        .foregroundColor(.txt06)
                }
                Spacer()
                Text(DateFormatter.customMonthFormatter.string(from: selectedDate))
                    .font(.montBold17)
                    .foregroundColor(.txt06)
                    .padding(.leading, 21)
                Spacer()
                Button(action: {
                    if isSelectionMode {
                        if hasSelection {
                            // ✅ "삭제" 텍스트 상태일 때
                            onDeleteSelected?()
                        } else {
                            // ✅ "완료" 텍스트 상태일 때
                            isSelectionMode = false
                        }
                    } else {
                        isSelectionMode = true
                    }
                }, label: {
                    Text(
                        !isSelectionMode ? "선택" :
                        (hasSelection ? "삭제" : "완료")
                    )
                    .foregroundColor(.txt06)
                })
            }
            .padding(.horizontal)
            .padding(.top)

            // 요일 및 날짜 표시 영역
            TabView(selection: $weekOffset) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
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
                    .tag(index - 2 + weekOffset)
                    .padding()
                }
            }
            .frame(height: 80)
            .tabViewStyle(.page)
        }
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
