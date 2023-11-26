//
//  ChessboardView.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import SwiftUI
import SwiftData

struct ChessboardView: View {
    @EnvironmentObject var chessBoard: ChessBoard
    @ObservedObject var viewModel: ChessBoardViewModel
    @State private var selectedPiece: BoardPosition?
    @State private var selectedPiecePosition: BoardPosition?
    @State private var isWhiteTurn = true
    
    let gradient = LinearGradient(
        colors: [
            Color(red: 116/255, green: 63/255, blue: 252/255), // Vibrant Purple
            Color(red: 179/255, green: 86/255, blue: 252/255)  // Light Purple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            Color.black
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 1) {
                    ForEach(0..<8, id: \.self) { row in
                        ForEach(0..<8, id: \.self) { column in
                            let position = BoardPosition(row: row, column: column)
                            let isLightSquare = (row + column) % 2 == 0
                            ChessSquareView(piece: chessBoard.piece(at: position),
                                            position: position,
                                            isLightSquare: isLightSquare,
                                            highlightColor: viewModel.highlightedSquares[position],
                                            isSelected: selectedPiecePosition == position)
                            .frame(width: 40, height: 40)
                            .id("\(row)-\(column)")
                            .onTapGesture {
                                handleSquareTap(at: position)
                            }
                        }
                    }
                }
                .background(gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .border(gradient, width: 5)
                
                Text("Explanation of Move: ")
                    .foregroundStyle(.white)
                    .font(.title2)
                Text(viewModel.lastExplanation)
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .padding()
                
                if viewModel.aiIsThinking {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .mint))
                        .background(Color.black.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    Text("AI is Thinking...")
                        .foregroundStyle(Color.mint)
                        .fontWeight(.heavy)
                        .font(.title2)
                }
                
                Spacer()
                VStack {
                    Toggle(isOn: $viewModel.isWhiteTurn) {
                        Text(viewModel.isWhiteTurn ? "White's Turn" : "Black's Turn")
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.firstMoveMade || ChessBoard.shared.firstMoveMade)
                    .onChange(of: viewModel.isWhiteTurn) {
                        if viewModel.isWhiteTurn {
                            chessBoard.isWhiteTurn = true
                        } else {
                            chessBoard.isWhiteTurn = false
                        }
                        if !viewModel.firstMoveMade &&  !ChessBoard.shared.firstMoveMade{
                            analyzeBoard()
                        }
                    }
                    .tint(gradient)
                    .padding()
                }
                .padding(10)
            }
            
        }
        .disabled(viewModel.aiIsThinking)
    }
    
    // when board state changes, update view
    private func updateViewOnBoardChange() {
        if chessBoard.boardStateChanged {
            
        }
    }
    
    
    func handleSquareTap(at position: BoardPosition) {
        if let selectedPosition = selectedPiecePosition {
            let moveSuccessful = viewModel.chessBoard.movePiece(from: selectedPosition, to: position)
            if moveSuccessful {
                viewModel.toggleTurn()
            }
            // reset the selected piece after attempt
            selectedPiecePosition = nil
        } else {
            selectedPiecePosition = position
            // could maybe highlight selected square here--
        }
    }
    
    func analyzeBoard() {
        viewModel.requestAnalysis()
    }
}
