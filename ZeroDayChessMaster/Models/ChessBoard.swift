//
//  ChessBoard.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import Foundation

struct Move {
    let piece: ChessPiece
    let from: BoardPosition
    let to: BoardPosition
}
extension Move {
    func notation() -> String {
        // Convert BoardPosition to chess notation
        func positionToNotation(_ position: BoardPosition) -> String {
            let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(position.column))!)
            let rowNumber = 8 - position.row
            return "\(columnLetter)\(rowNumber)"
        }

        let fromNotation = positionToNotation(from)
        let toNotation = positionToNotation(to)
        return "\(fromNotation)-\(toNotation)"
    }
}


class ChessBoard: ObservableObject {
    @Published var board: [[ChessPiece?]]
    static let shared = ChessBoard()
    
    init() {
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        setupInitialPositions()
    }
    
    @Published var boardStateChanged = false
    var lastMove: Move?
    @Published var startingPosition: BoardPosition?
    @Published var firstMoveMade: Bool = false
    
    @Published var isWhiteTurn: Bool = true
    

    private func setupInitialPositions() {
        // Set up initial positions for pieces
        // Add pawns
        for column in 0..<8 {
            board[1][column] = Pawn(type: .pawn, color: .black, currentPosition: BoardPosition(row: 1, column: column))
            board[6][column] = Pawn(type: .pawn, color: .white, currentPosition: BoardPosition(row: 6, column: column))
        }
        // Add other pieces (Rooks, Knights, Bishops, Queens, Kings)
        for color in [PieceColor.black, PieceColor.white] {
            let row = (color == .black) ? 0 : 7
            
            // Rooks:
            board[row][0] = Rook(type: .rook, color: color, currentPosition: BoardPosition(row: row, column: 0))
            board[row][7] = Rook(type: .rook, color: color, currentPosition: BoardPosition(row: row, column: 7))
            
            // Knights:
            board[row][1] = Knight(type: .knight, color: color, currentPosition: BoardPosition(row: row, column: 1))
            board[row][6] = Knight(type: .knight, color: color, currentPosition: BoardPosition(row: row, column: 6))
            
            // Bishops:
            board[row][2] = Bishop(type: .bishop, color: color, currentPosition: BoardPosition(row: row, column: 2))
            board[row][5] = Bishop(type: .bishop, color: color, currentPosition: BoardPosition(row: row, column: 5))
            
            // King & Queen:
            board[row][3] = King(type: .king, color: color, currentPosition: BoardPosition(row: row, column: 3))
            board[row][4] = Queen(type: .queen, color: color, currentPosition: BoardPosition(row: row, column: 4))
            
        }
    }
    
    func piece(at position: BoardPosition) -> ChessPiece? {
        guard position.row >= 0, position.row < 8, position.column >= 0, position.column < 8 else {
            return nil
        }
        return board[position.row][position.column]
    }
    
    func movePiece(from start: BoardPosition, to end: BoardPosition) -> Bool {
        print("Attempting to move piece from \(start) to \(end)")
        printBoardState()
        guard let piece = board[start.row][start.column] else {
            print("No piece at starting position.")
            return false
        }
        if (piece.color == .white && !isWhiteTurn) || (piece.color == .black && isWhiteTurn) {
            return false
        }

        let legalMoves = piece.possibleMoves(board: self)
        print("Legal moves for piece at \(start): \(legalMoves)")
        if !legalMoves.contains(end) {
            print("Move to \(end) is not legal for \(piece).")
            return false
        }

        // perform move
        board[end.row][end.column] = piece
        board[start.row][start.column] = nil

        // Update the piece's current position
        // **might need a way to update the piece's currentPosition in board array**
        updatePiecePosition(piece: piece, to: end)

        // Record the last move
        lastMove = Move(piece: piece, from: start, to: end)

        // Notify the view about state change
        objectWillChange.send()

        printBoardState() // Print state after the move
        print("Move successful: \(piece.type) moved from \(start) to \(end)")
        startingPosition = nil
        firstMoveMade = true
        return true
    }

    private func updatePiecePosition(piece: ChessPiece, to newPosition: BoardPosition) {
        // Find the piece in the board array and update its position
        for row in board.indices {
            for column in board[row].indices {
                if board[row][column] === piece {
                    board[row][column]?.currentPosition = newPosition
                    break
                }
            }
        }
    }
    
    func printBoardState() {
        print("Current board state:")
        for row in board.enumerated().reversed() {
            let rowString = row.element.enumerated().map { index, piece in
                if let piece = piece {
                    return "\(piece.color == .white ? "W" : "B")\(piece.type.abbreviation)"
                } else {
                    return " . "
                }
            }.joined(separator: " ")
            print("Row \(8 - row.offset): \(rowString)")
        }
    }
    
    func getFormattedBoardState() -> String {
        var state: [String] = []

        for (rowIndex, row) in board.enumerated() {
            for (columnIndex, piece) in row.enumerated() {
                if let piece = piece {
                    let position = formatPosition(row: rowIndex, column: columnIndex)
                    let pieceInfo = formatPieceInfo(piece)
                    state.append("\(position):\(pieceInfo)")
                }
            }
        }
        
        let turnInfo = "Turn:White"
        state.append(turnInfo)

        return state.joined(separator: ", ")
    }

    private func formatPosition(row: Int, column: Int) -> String {
        let columnLetter = String(UnicodeScalar("A".unicodeScalars.first!.value + UInt32(column))!)
        let rowNumber = 8 - row
        return "\(columnLetter)\(rowNumber)"
    }

    private func formatPieceInfo(_ piece: ChessPiece) -> String {
        let color = (piece.color == .white) ? "W" : "B"
        let type: String
        switch piece {
        case is Pawn:
            type = "P"
        case is Rook:
            type = "R"
        case is Knight:
            type = "N"
        case is Bishop:
            type = "B"
        case is Queen:
            type = "Q"
        case is King:
            type = "K"
        default:
            type = ""
        }
        return "\(color)\(type)"
    }
}
