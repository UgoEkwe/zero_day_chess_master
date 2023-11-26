//
//  ChessBoardViewModel.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import Foundation
import SwiftUI

class ChessBoardViewModel: ObservableObject {
    
    var chessBoard: ChessBoard

    init(chessBoard: ChessBoard) {
        self.chessBoard = chessBoard
    }
    
    @Published var isWhiteTurn: Bool = true
    @Published var aiIsThinking: Bool = false
    
    @Published var chessboardState: String = ""
    @Published var analysisResult: String = ""
    @Published var lastExplanation: String = ""
    @Published var lastMoveNotation: String = ""
    @Published var firstMoveMade: Bool = false
    
    @Published var moveUnsuccessful: Bool = false
    @Published var unsuccessfullMsg: String = ""
    @Published var failedMovebyAI: String = ""
    
    @Published var highlightedSquares: [BoardPosition: Color] = [:]
    
    // determine pos of current poiece in standard notation
    private func parsePosition(from notation: String) -> BoardPosition? {
        let rowIndices = "87654321"
        let colIndices = "ABCDEFGH"

        guard notation.count == 2,
              let colIdx = colIndices.firstIndex(of: notation.first!),
              let rowIdx = rowIndices.firstIndex(of: notation.last!) else { return nil }

        return BoardPosition(row: rowIndices.distance(from: rowIndices.startIndex, to: rowIdx),
                             column: colIndices.distance(from: colIndices.startIndex, to: colIdx))
    }

    func toggleTurn() {
           isWhiteTurn.toggle()
           if !isWhiteTurn {
               // request analysis when it's black's turn
               aiIsThinking = true // to display progress view while waiting for request
               requestAnalysis()
           }
       }

       func requestAnalysis() {
           chessboardState = chessBoard.getFormattedBoardState()
           if !isWhiteTurn {
               analyzeChessBoard(chessboard: chessboardState)
           }
       }
    
    func analyzeChessBoard(chessboard: String) {
        if let lastMoveCheck = ChessBoard.shared.lastMove?.notation() {
            lastMoveNotation = lastMoveCheck
        } else {
            lastMoveNotation = "No move made yet"
        }
        
        if moveUnsuccessful {
            unsuccessfullMsg = "The last moves you tried were \(failedMovebyAI) and it was unsuccessful. The next move you make cannot be \(failedMovebyAI). Possibly because it was an illegal move. Please try a different move, here's the prompt: "
            lastMoveNotation = ""
        }
        
        NetworkManager.shared.sendRequestToAI(chessboard: chessboard, lastMove: lastMoveNotation, lastExplanation: lastExplanation, unsuccessfulMsg: unsuccessfullMsg) { [weak self] response in
               if let analysis = response {
                   if !(self?.isWhiteTurn ?? true) {
                       // if it's black's turn, attempt make the AI's suggested move
                       self?.makeAIMove(analysis)
                   }
               }
           }
       }

    private func makeAIMove(_ analysis: String) {
        // split response into move and explanation
        let components = analysis.split(separator: "\n", omittingEmptySubsequences: true)
        guard components.count >= 2,
              let moveNotation = components.first?.trimmingCharacters(in: .whitespaces) else {
            print("Invalid AI response format")
            return
        }

        // parse move notation
        let positions = moveNotation.split(separator: "-")
        guard positions.count == 2,
              let fromPosition = parsePosition(from: String(positions[0])),
              let toPosition = parsePosition(from: String(positions[1])) else {
            print("Invalid move notation")
            return
        }
        
        // perform move
        if chessBoard.movePiece(from: fromPosition, to: toPosition) {
            firstMoveMade = true
            print("AI Move successful: \(moveNotation)")
            let explanation = components.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespaces)
            lastExplanation = explanation
            failedMovebyAI = ""
            aiIsThinking = false
            chessBoard.objectWillChange.send()
            toggleTurn()
        } else {
            // AI made illegal move so retry after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if self.failedMovebyAI != "" {
                    self.failedMovebyAI += "," + moveNotation
                } else {
                    self.failedMovebyAI = moveNotation
                }
                self.moveUnsuccessful = true
                self.requestAnalysis()
            }
            print("AI Move failed: \(moveNotation)")
        }
    }
    
    private func updateBoardState(with analysis: String) {
        self.analysisResult = analysis
    }
}
