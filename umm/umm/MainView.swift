import SwiftUI
import Foundation

struct MainView: View {
  let calendar = Calendar.current
  @State private var selectedDate: Date = Date()
  @State private var showDatePicker = false
  @State private var weekOffset: Int = 0

  var body: some View {

    ZStack {
      BackgorounView()
      CalendarView(
        calendar: calendar,
        selectedDate: $selectedDate,
        showDatePicker: $showDatePicker,
        weekOffset: $weekOffset
      )
    }
  }
}

#Preview {
  MainView()
}
