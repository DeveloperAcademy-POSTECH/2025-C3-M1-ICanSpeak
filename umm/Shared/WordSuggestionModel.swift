//
//  WordSuggestionModel.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import SwiftUI

struct WordSuggestion: Codable, Identifiable {
    var id = UUID()
    let word: String        // 예: invite
    let partOfSpeech: String // 예: (v)
    let meaning: String     // 예: 초대하다
    let example: String     // 예: I invited my friend.
}
