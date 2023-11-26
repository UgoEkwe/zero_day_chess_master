//
//  ZeroDayChessMasterApp.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import SwiftUI
import SwiftData

@main
struct ZeroDayChessMasterApp: App {
    let chessBoard = ChessBoard()
    var body: some Scene {
        WindowGroup {
            ChessboardView(viewModel: ChessBoardViewModel(chessBoard: chessBoard))
                .environmentObject(chessBoard)
        }
    }
}
