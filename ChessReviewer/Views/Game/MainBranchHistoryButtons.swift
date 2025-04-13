//
//  MainBranchHistoryButtons.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/4/6.
//

import SwiftUI

struct MovesButtonModel: Identifiable {
    var id: Int
    var move: String
}

struct MainBranchHistoryButtons: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(getMoveButtonModels()) { model in
                        Text("\(model.id + 1):")
                        let currentRoundMoves = model.move.split(separator: " ").map(String.init)
                        HistoryBottonsInARound(roundIndex: model.id, movesInARound: currentRoundMoves)
                    }
                    Color.clear
                        .frame(width: 1)
                        .id("trailing")
                }
            }
            .onChange(of: gameManager.moveRecorder.mainBranchMovesString) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    withAnimation() {
                        scrollProxy.scrollTo("trailing", anchor: .trailing)
                    }
                }
            }
        }
        .frame(height: 25)
        .padding([.leading, .trailing], 20)
    }
    
    private func HistoryBottonsInARound(roundIndex: Int, movesInARound: [String]) -> some View {
        HStack {
            ForEach(0 ..< 2) { moveIndexInRound in
                if movesInARound.count > moveIndexInRound {
                    Button {
                        print("回到第\(roundIndex + 1)回合的\(moveIndexInRound == 0 ? "白" : "黑")方走棋后的样子")
                    } label: {
                        Text(movesInARound[moveIndexInRound])
                            .padding([.leading, .trailing], 5)
                            .padding([.top, .bottom], 3)
                            .foregroundColor(.primary)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
    
    private func getMoveButtonModels() -> [MovesButtonModel] {
        gameManager.moveRecorder.mainBranchRoundsArray.enumerated().map { index, move in
            MovesButtonModel(id: index, move: move)
        }
    }
}

struct MainBranchHistoryButtons_Previews: PreviewProvider {
    static var previews: some View {
        let gameManager = GameManager(
            gameBuilder: InitialGameBuilder(
                gameMode: .pvp, historyControlMode: .playStrict
            )
        )
        if let gameManager = gameManager {
            MainBranchHistoryButtons(gameManager: gameManager)
        } else {
            Text("gameBuilder 配置有误")
        }
    }
}
