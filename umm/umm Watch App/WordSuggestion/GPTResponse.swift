//
//  GPTResponse.swift
//  umm
//
//  Created by Youbin on 5/30/25.
//

import SwiftUI

struct GPTResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}
