//
//  WordSuggestionModel.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import SwiftUI

struct ConversationSession: Identifiable, Codable {
    var id = UUID()
    let startTime: Date
    var endTime: Date?
    var groups: [WordSuggestionGroup]
}


struct WordSuggestionGroup: Identifiable, Codable {
    var id = UUID()
    let keyword: String
    let suggestions: [WordSuggestion]
}

struct WordSuggestion: Identifiable, Codable {
    var id = UUID()
    let word: String
    let partOfSpeech: String
    let meaning: String
    let example: String
}
