//
//  Game.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Game: View {
    @StateObject private var piecesManager = PiecesManager()
    
    var body: some View {
        VStack {
            Text("selected: " + (piecesManager.selectedPiece?.pieceCommonName ?? "not selected"))
            ZStack {
                Board(piecesManager: piecesManager)
                PiecesLayer(pieces: $piecesManager.pieces) { piece, position in
                    
                }
            }
        }
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
