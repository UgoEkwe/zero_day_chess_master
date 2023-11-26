//
//  ChessPiece.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import Foundation

protocol ChessPiece: AnyObject {
    var color: PieceColor { get set }
    var currentPosition: BoardPosition { get set }
    var type: PieceType { get set }
    func possibleMoves(board: ChessBoard) -> [BoardPosition]
}

enum PieceColor {
    case white, black
}

enum PieceType {
    case pawn, rook, knight, bishop, king, queen

    var abbreviation: String {
        switch self {
        case .pawn: return "P"
        case .rook: return "R"
        case .knight: return "N" // to avoid confusion with King
        case .bishop: return "B"
        case .king: return "K"
        case .queen: return "Q"
        }
    }
}

struct BoardPosition: Equatable, Hashable {
    let row: Int
    let column: Int
}

class Pawn: ChessPiece {
    var type: PieceType = .pawn
    var color: PieceColor
    var currentPosition: BoardPosition

    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        var moves = [BoardPosition]()
        
        
        let direction = color == .white ? -1 : 1 // Invert the direction for white
        let startingRow = color == .white ? 6 : 1 // Adjust the starting row for zero-indexing
        let nextRow = currentPosition.row + direction
        
        // Forward move check
        let forwardMove = BoardPosition(row: nextRow, column: currentPosition.column)
        if nextRow >= 0 && nextRow < 8, board.piece(at: forwardMove) == nil {
            moves.append(forwardMove)
            
            // Double forward move check
            if currentPosition.row == startingRow {
                let doubleForwardMove = BoardPosition(row: nextRow + direction, column: currentPosition.column)
                if nextRow + direction >= 0 && nextRow + direction < 8, board.piece(at: doubleForwardMove) == nil {
                    moves.append(doubleForwardMove)
                }
            }
        }
        
        // Diagonal capture checks
        let diagonals = [(-1, direction), (1, direction)]
        for (colOffset, rowOffset) in diagonals {
            let diagonalMove = BoardPosition(row: currentPosition.row + rowOffset, column: currentPosition.column + colOffset)
            print("Checking diagonal move to \(diagonalMove)")
            if let piece = board.piece(at: diagonalMove), piece.color != self.color {
                moves.append(diagonalMove)
                print("Added capture move to \(diagonalMove)")
            }
        }
        
        // Print all possible moves before returning
        print("Possible moves for pawn at \(currentPosition): \(moves)")
        return moves
    }
}

class Rook: ChessPiece {
    var type: PieceType = .rook
    var color: PieceColor
    var currentPosition: BoardPosition
    
    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        var moves = [BoardPosition]()
        // Vertical moves
        for i in 0..<8 {
            let pos = BoardPosition(row: i, column: currentPosition.column)
            if i != currentPosition.row, let piece = board.piece(at: pos), piece.color != self.color {
                moves.append(pos)
            }
        }
        // Horizontal moves
        for j in 0..<8 {
            let pos = BoardPosition(row: currentPosition.row, column: j)
            if j != currentPosition.column, let piece = board.piece(at: pos), piece.color != self.color {
                moves.append(pos)
            }
        }
        return moves
    }
}

class Knight: ChessPiece {
    var type: PieceType = .knight
    var color: PieceColor
    var currentPosition: BoardPosition
    
    let directions = [
        (-1,-2), // Bottom-Left
        (-2,-1), // Bottom-Left
        (-1,2),  // Upper-Left
        (-2,1),  // Upper-Left
        (1,-2),  // Bottom-Right
        (2,-1),  // Bottom-Right
        (1,2),   // Upper-Right
        (2,1),   // Upper-Right
    ]
    
    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        // Calculate possible moves for knight
        var moves = [BoardPosition]()
        // Move vertically by 1 (or 2) and horizontally by 2 (or 1)
        let currentPos = currentPosition
        for direction in directions {
            //  Calculate the location of new move
            let xNew = currentPos.row + direction.0
            let yNew = currentPos.column + direction.1
            // If the new move does not cross the boundary add it to array
            if (xNew >= 0 && xNew <= 7) && (yNew >= 0 && yNew <= 7) {
                let newPos = BoardPosition(row: xNew, column: yNew)
                if let piece = board.piece(at: newPos), piece.color != self.color {
                    moves.append(newPos)
                }
            }
        }
        return moves
    }
}

class Bishop: ChessPiece {
    var type: PieceType = .bishop
    var color: PieceColor
    var currentPosition: BoardPosition
    
    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        var moves = [BoardPosition]()
        let directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)] // Diagonal moves
        for direction in directions {
            var currentPos = currentPosition
            while true {
                currentPos = BoardPosition(row: currentPos.row + direction.0, column: currentPos.column + direction.1)
                // filter out of bounds moves
                if currentPos.row < 0 || currentPos.row > 7 || currentPos.column < 0 || currentPos.column > 7 {
                    break
                }
                if let piece = board.piece(at: currentPos) {
                    if piece.color != self.color {
                        moves.append(currentPos)
                    }
                    break
                } else {
                    moves.append(currentPos) // pass empty squares
                }
            }
        }
        return moves
    }
}

class Queen: ChessPiece {
    var type: PieceType = .queen
    var color: PieceColor
    var currentPosition: BoardPosition
    let directions = [
        (-1,  0), // Up
        ( 1,  0), // Down
        ( 0,  1), // Right
        ( 0, -1), // Left
        (-1, -1), // Top-Left
        (-1,  1), // Top-Right
        ( 1, -1), // Bottom-Left
        ( 1,  1)  // Bottom-Right
    ]
    
    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        // Calculate possible moves for queen
        var moves = [BoardPosition]()
        // Move vertically, horizontally, or diagonally in any direction
        for direction in directions {
            var currentPos = currentPosition
            while true {
                currentPos = BoardPosition(row: currentPos.row + direction.0, column: currentPos.column + direction.1)
                
                if currentPos.row < 0 || currentPos.row > 7 || currentPos.column < 0 || currentPos.column > 7 {
                    break
                }
                if let piece = board.piece(at: currentPos) {
                    if piece.color != self.color {
                        moves.append(currentPos)
                    }
                    break
                } else {
                    moves.append(currentPos)
                }
                
            }
        }
        return moves
    }
}

class King: ChessPiece {
    var type: PieceType = .king
    var color: PieceColor
    var currentPosition: BoardPosition
    
    let directions = [
        (-1,  0), // Up
        ( 1,  0), // Down
        ( 0,  1), // Right
        ( 0, -1), // Left
        (-1, -1), // Top-Left
        (-1,  1), // Top-Right
        ( 1, -1), // Bottom-Left
        ( 1,  1)  // Bottom-Right
    ]
    
    init(type: PieceType, color: PieceColor, currentPosition: BoardPosition) {
        self.type = type
        self.color = color
        self.currentPosition = currentPosition
    }
    
    func possibleMoves(board: ChessBoard) -> [BoardPosition] {
        // Calculate possible moves for king
        var moves = [BoardPosition]()
        // Move vertically, horizontally, or diagonally as long as not exposed after move
        for direction in directions {
            let newRow = currentPosition.row + direction.0
            let newColumn = currentPosition.column + direction.1
            
            if (newRow >= 0 && newRow <= 7) && (newColumn >= 0 && newColumn <= 7) {
                let newPos = BoardPosition(row: newRow, column: newColumn)
                if let piece = board.piece(at: newPos) {
                    if piece.color != self.color {
                        moves.append(newPos)
                    }
                } else {
                    moves.append(newPos)
                }
            }
        }
        return moves
    }
}
