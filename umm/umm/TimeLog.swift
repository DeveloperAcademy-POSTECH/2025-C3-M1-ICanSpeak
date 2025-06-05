//
//  TimeLog.swift
//  umm
//
//  Created by 강진 on 6/4/25.
//

import Foundation

struct TimeLog: Codable, Identifiable {
    let id = UUID()
    var start: Date
    var exit: Date?
}
