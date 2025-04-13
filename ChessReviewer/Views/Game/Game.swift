//
//  Game.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Game: View {
    @StateObject var gameManager: GameManager
    @State var boardReversed: Bool = false
    
    var body: some View {
        VStack {
            Text(getGameState())
                .frame(height: 20)
            MainBranchHistoryButtons(gameManager: gameManager)
            Text(gameManager.moveRecorder.currentMove?.fen?.toString() ?? FEN.initialGameFEN().toString())
                .textSelection(.enabled)
            ZStack {
                Board(reversed: boardReversed) { _ in
                    gameManager.selectedPieceIndex = nil
                }
                PiecesLayer(gameManager: gameManager, onReversedBoard: boardReversed)
            }
            .padding()
            HStack {
                Button {
                    boardReversed.toggle()
                } label: {
                    Text("翻转棋盘")
                }
                Button {
                    print("position startpos moves " + gameManager.moveRecorder.mainBranchMovesString)
                } label: {
                    Text("打印棋谱")
                }
                Button {
                    gameManager.resetGame()
                } label: {
                    Text("重置局面")
                }
            }
            .padding([.bottom], 10)
            HStack {
                Button {
                    gameManager.stepBackward()
                } label: {
                    Text("上一步")
                }
                Button {
                    gameManager.stepForward()
                } label: {
                    Text("下一步")
                }
            }
        }
    }
    
    private func getGameState() -> String {
        if let sideInCheckmate = gameManager.sideInCheckmate {
            return "Checkmate to \(sideInCheckmate == .white ? "white" : "black")!"
        } else if gameManager.threefoldRepetition {
            return "threefold repetition"
        } else if gameManager.impossibleToCheckmate {
            return "insufficient material"
        } else if let sideInCheck = gameManager.sideInCheck {
            return "Check to \(sideInCheck == .white ? "white" : "black")!"
        } else if let sideInStalemate = gameManager.sideInStalemate {
            return "Stalemate to \(sideInStalemate == .white ? "white" : "black")!"
        }
        return ""
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        let gameManager = GameManager(
            gameBuilder: InitialGameBuilder(
                gameMode: .pvp, historyControlMode: .playStrict
            )
        )
        if let gameManager = gameManager {
            Game(gameManager: gameManager)
        } else {
            Text("gameBuilder 配置有误")
        }
    }
}
