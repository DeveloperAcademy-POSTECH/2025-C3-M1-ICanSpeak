//
//  DateFormatter.swift
//  umm
//
//  Created by Youbin on 6/10/25.
//

import Foundation

extension Date {
    func formatForSessionCard() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }

    func formatForDetailHeader() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM d 'at' h:mma"
        return formatter.string(from: self)
    }
}
