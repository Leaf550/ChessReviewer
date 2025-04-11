//
//  Game.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Game: View {
    @StateObject private var piecesManager = PiecesManager()
    @State var boardReversed: Bool = false
    
    var body: some View {
        VStack {
            Text(getGameState())
                .frame(height: 20)
            MainBranchHistoryButtons(piecesManager: piecesManager)
            Text(piecesManager.moveRecorder.currentMove?.fen?.toString() ?? FEN.initialGameFEN().toString())
                .textSelection(.enabled)
            ZStack {
                Board(reversed: boardReversed) { _ in
                    piecesManager.selectedPieceIndex = nil
                }
                PiecesLayer(piecesManager: piecesManager, onReversedBoard: boardReversed)
            }
            .padding()
            HStack {
                Button {
                    boardReversed.toggle()
                } label: {
                    Text("翻转棋盘")
                }
                Button {
                    print("position startpos moves " + piecesManager.moveRecorder.mainBranchMovesString)
                } label: {
                    Text("打印棋谱")
                }
            }
        }
    }
    
    private func getGameState() -> String {
        if let sideInCheckmate = piecesManager.sideInCheckmate {
            return "Checkmate to \(sideInCheckmate == .white ? "white" : "black")!"
        } else if piecesManager.threefoldRepetition {
            return "threefold repetition"
        } else if piecesManager.impossibleToCheckmate {
            return "insufficient material"
        } else if let sideInCheck = piecesManager.sideInCheck {
            return "Check to \(sideInCheck == .white ? "white" : "black")!"
        } else if let sideInStalemate = piecesManager.sideInStalemate {
            return "Stalemate to \(sideInStalemate == .white ? "white" : "black")!"
        }
        return ""
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
