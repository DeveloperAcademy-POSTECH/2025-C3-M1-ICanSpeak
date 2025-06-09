//
//  MonthlyDatePickerView.swift
//  umm
//
//  Created by MINJEONG on 6/9/25.
//

import SwiftUI

struct MonthlyDatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            ZStack {
                Color.white.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
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
}

#Preview {
    StatefulPreviewWrapper(Date(), true) { date, isPresented in
        MonthlyDatePickerView(selectedDate: date, isPresented: isPresented)
    }
}

struct StatefulPreviewWrapper<T1, T2, Content: View>: View {
    @State private var value1: T1
    @State private var value2: T2
    let content: (Binding<T1>, Binding<T2>) -> Content

    init(_ value1: T1, _ value2: T2, content: @escaping (Binding<T1>, Binding<T2>) -> Content) {
        _value1 = State(initialValue: value1)
        _value2 = State(initialValue: value2)
        self.content = content
    }

    var body: some View {
        content($value1, $value2)
    }
}
