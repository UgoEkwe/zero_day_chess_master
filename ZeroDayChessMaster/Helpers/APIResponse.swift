//
//  APIResponse.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import Foundation

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

struct Choice: Codable {
    let text: String
    let finishReason: String
    let index: Int
}
