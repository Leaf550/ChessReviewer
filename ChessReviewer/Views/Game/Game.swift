//
//  Game.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Game: View {
    @StateObject private var piecesManager = PiecesManager()
    
    private var couldMovePositions: [BoardIndex] {
        piecesManager.selectedPiecePossibleMovements.map { $0.to }
    }
    
    var body: some View {
        VStack {
            Text("selected: " + (piecesManager.selectedPiece?.pieceCommonName ?? "not selected"))
            ZStack {
                Board() { _ in 
                    piecesManager.selectedPieceIndex = nil
                }
                PiecesLayer(piecesManager: piecesManager)
            }.padding()
        }
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
