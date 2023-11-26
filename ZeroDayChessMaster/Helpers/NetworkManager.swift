//
//  NetworkFunction.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import Foundation
import SwiftUI
import Combine

class NetworkManager: NSObject, ObservableObject {
    
    static let shared = NetworkManager()
    var openApiKey: String?
    
    override init() {
        super.init()
        openApiKey = getOpenAPIKey()
    }
    
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    private var cancellable: AnyCancellable?
    
    private func getOpenAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let keys = NSDictionary(contentsOfFile: path),
              let apiKey = keys["OpenAPI"] as? String else {
            print("Error: Couldn't load API key")
            return nil
        }
        return apiKey
    }
    
    func sendRequestToAI(chessboard: String, lastMove: String, lastExplanation: String, unsuccessfulMsg: String, completion: @escaping (String?) -> Void) {
        let prompt = """
        \(unsuccessfulMsg)
        Chessboard state: \(chessboard)
        Last move by white: \(lastMove)
        Previous AI explanation: \(lastExplanation)
        
        Please provide the next move for the black player in standard chess notation (e.g., E6-E5) followed by an explanation for the move. Under no circumstances do you make an illegal move. For example a pawn moving from D5-E4 with no opposing piece to capture in E4 is an illegal move. Your goal is to win the game against the white player. The format of your response should look like this: E6-E5\nExplanation.
        """
        
        let headers = ["Content-Type": "application/json", "Authorization": "Bearer \(openApiKey!)"]
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "\(unsuccessfulMsg) You are a Chess Engine with the goal of beating the white player in chess. Analyze the given chessboard state. Provide only the next move for the black player in standard chess notation followed by an endline and an explanation for that move. Do not include any additional information or context in your responses. Under no circumstances do you make an illegal move or attempt to move a white piece. Here's an example to understand the pieces in the chessboard state: G8:BN corresponds to a Black Knight at cell G8; BP = black pawn, BR = black rook, BN = black knight, BB = black bishop, BQ = black queen, BK = black king. The format of your response should look like this: E6-E5\nExplanation"],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 150,
            "temperature": 0.4
        ]
        
        
        let finalBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = finalBody
        
        print("Sending request to OpenAI API...") // Print statement to indicate request is starting
        if let httpBody = request.httpBody, let requestBody = String(data: httpBody, encoding: .utf8) {
            print("Request Body: \(requestBody)")
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    print("Error: Invalid response received.") // Print statement for invalid response
                    throw URLError(.badServerResponse)
                }
                
                print("Response status code: \(response.statusCode)") // status code
                if response.statusCode != 200 {
                    print("Response headers: \(response.allHeaderFields)") // Print header if status code is not 200
                    print("Response body: \(String(data: output.data, encoding: .utf8) ?? "No data")") // Print body for non-200 response
                    throw URLError(.badServerResponse)
                }
                
                return output.data
            }
            .decode(type: OpenAIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .failure(let error):
                    print("Network request failed with error: \(error)") // Print statement for request failure
                    completion(nil)
                case .finished:
                    print("Network request finished successfully.") // Print statement for request completion
                }
            }, receiveValue: { openAIResponse in
                if let response = openAIResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) {
                    completion(response)
                } else {
                    print("No valid response content received.") // Print if no valid response content
                    completion(nil)
                }
            })
    }
}
