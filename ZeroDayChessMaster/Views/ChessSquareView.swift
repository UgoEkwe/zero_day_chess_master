//
//  ChessPieceShapes.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/23/23.
//

import Foundation
import SwiftUI

struct ChessSquareView: View {
    var piece: ChessPiece?
    var position: BoardPosition
    var isLightSquare: Bool
    var highlightColor: Color?
    var isSelected: Bool
    
    private var isBottomRow: Bool {
        position.row == 7
    }

    private var isLeftColumn: Bool {
        position.column == 0
    }

    private var rowLabel: String {
        String(8 - position.row)
    }

    private var columnLabel: String {
        ["A", "B", "C", "D", "E", "F", "G", "H"][position.column]
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(highlightColor ?? (isLightSquare ? Color.gray.opacity(0.5) : Color.indigo))
                .border(Color.gray, width: 1)
            
            Text(pieceRepresentation())
                .font(.largeTitle)
                .foregroundStyle(piece?.color == .white ? Color.white : Color.black)
            
            GeometryReader { geometry in
                VStack {
                    HStack {
                        if isLeftColumn {
                            Text(rowLabel)
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                                .padding([.top, .leading], 4)
                        }
                        Spacer()
                    }
                    Spacer(minLength: 1)
                    HStack {
                        Spacer(minLength: 1)
                        if isBottomRow {
                            Text(columnLabel)
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomTrailing)
                                .padding([.bottom, .trailing], 2)
                        }
                    }
                }
            }
            Rectangle()
                .fill(.clear)
                .border(isSelected ? Color.white : Color.gray, width: isSelected ? 3 : 1) // Adjust thickness as needed
            
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func pieceRepresentation() -> String {
        guard let piece = piece else {
            return ""
        }
        
        switch piece.type {
        case .pawn:
            return "♟︎"
        case .rook:
            return "♜"
        case .knight:
            return "♞"
        case .bishop:
            return "♝"
        case .queen:
            return "♛"
        case .king:
            return "♚"
        }
    }
}

// SHAPE REPRESENTATIONS FOR CHESS PIECES
// SPENT HOURS BUILDING THESE BEFORE REMEMBERING AN EASY SOLUTION
// DIDN'T HAVE THE HEART TO DELETE

//
//struct ChessSquareView: View {
//    var piece: ChessPiece?
//    var highlightColor: Color?
//    var isLightSquare: Bool
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(isLightSquare ? Color.gray.opacity(0.5) : Color.indigo)
//                .border(Color.gray, width: 1)
//            switch piece?.type {
//            case .pawn:
//                PawnView(piece: piece)
//            case .rook:
//                RookView(piece: piece)
//            case .knight:
//                KnightView(piece: piece)
//            case .bishop:
//                BishopView(piece: piece)
//            case .king:
//                KingView(piece: piece)
//            case .queen:
//                QueenView(piece: piece)
//            default:
//                EmptyView()
//            }
//        }
//        .aspectRatio(1, contentMode: .fit)
//    }
//}
//
//
//struct PawnView: View {
//    var piece: ChessPiece?
//    var body: some View {
//        VStack(spacing: 0) {
//            Circle() // Head
//                .frame(width: 20, height: 10)
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//            Rectangle() // Body
//                .frame(width: 8, height: 15)
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                .clipShape(.rect(cornerRadius: 20))
//        }
//    }
//}
//
//struct RookView: View {
//    var piece: ChessPiece?
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Rectangle() // Battlement
//                    .frame(width: 3, height: 3)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .padding(.leading)
//                Spacer()
//                Rectangle() // Battlement
//                    .frame(width: 3, height: 3)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .padding(.trailing)
//            }
//            .padding(.bottom, -2)
//            Rectangle() // Head
//                .frame(width: 13, height: 13)
//                .clipShape(.rect(cornerRadius: 3))
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                .padding(.bottom, -6)
//            Rectangle() // Body
//                .frame(width: 8, height: 15)
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//        }
//    }
//}
//
//struct KnightView: View {
//    var piece: ChessPiece?
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(piece?.color == .black ? Color.black : Color.white, lineWidth: 2)
//                .frame(width: 25, height: 25)
//            Text("K")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(piece?.color == .black ? .black : .white)
//                .frame(width: 20, height: 20)
//        }
//    }
//}
//
//struct BishopView: View {
//    var piece: ChessPiece?
//    var body: some View {
//        VStack (spacing: 0) {
//            ZStack {
//                Triangle()
//                    .frame(width: 15, height: 15)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .padding(.bottom, 10)
//                Circle()
//                    .frame(width: 15, height: 15)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                Rectangle() // Body
//                    .frame(width: 8, height: 15)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .padding(.top, 20)
//                
//            }
//            .padding(.bottom, 5)
//        }
//    }
//    
//    private func Triangle() -> some View {
//        Path { path in
//            path.move(to: CGPoint(x: 7.5, y: 0)) // Top point triangle
//            path.addLine(to: CGPoint(x: 15, y: 15)) // Bottom right of triangle
//            path.addLine(to: CGPoint(x: 0, y: 15)) // Bottom leftof triangle
//            path.closeSubpath()
//        }
//    }
//}
//
//
//struct KingView: View {
//    var piece: ChessPiece?
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(piece?.color == .black ? Color.black : Color.white, lineWidth: 2)
//                .frame(width: 25, height: 25)
//            Circle()
//                .fill(Color(red: 1.0, green: 0.843, blue: 0))
//                .frame(width: 25, height: 25)
//            Text("K")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(piece?.color == .black ? .black : .white)
//                .frame(width: 20, height: 20)
//        }
//    }
//}
//struct QueenView: View {
//    var piece: ChessPiece?
//    
//    var body: some View {
//        VStack {
//            HStack(spacing: -5) { // Crown
//                // Left, rotated -40 degrees
//                Triangle()
//                    .frame(width: 10, height: 10)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .rotationEffect(.degrees(-40))
//                
//                Triangle()
//                    .frame(width: 10, height: 10)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                
//                // Right, rotated 40 degrees
//                Triangle()
//                    .frame(width: 10, height: 10)
//                    .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                    .rotationEffect(.degrees(40))
//            }
//            .padding(.bottom, -10)
//            Circle() // Head
//                .frame(width: 15, height: 15)
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//                .padding(.bottom, -15)
//            Rectangle() // Body
//                .frame(width: 7, height: 15)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//                .foregroundStyle(piece?.color == .black ? Color.black : Color.white)
//        }
//    }
//    
//    private func Triangle() -> some View {
//        Path { path in
//            path.move(to: CGPoint(x: 5, y: 0)) // Top point triangle
//            path.addLine(to: CGPoint(x: 10, y: 10)) // Bottom right
//            path.addLine(to: CGPoint(x: 0, y: 10)) // Bottom left
//            path.closeSubpath()
//        }
//    }
//}
