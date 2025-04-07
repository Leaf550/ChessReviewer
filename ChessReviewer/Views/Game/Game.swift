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
            Text(getCheckTitle())
                .frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                Text(getMovesString())
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(height: 20)
            .padding([.leading, .trailing], 20)
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
            }
        }
    }
    
    private func getCheckTitle() -> String {
        if let sideInCheckmate = piecesManager.sideInCheckmate {
            return "Checkmate to \(sideInCheckmate == .white ? "white" : "black")!"
        } else if let sideInCheck = piecesManager.sideInCheck {
            return "Check to \(sideInCheck == .white ? "white" : "black")!"
        }
        return ""
    }
    
    private func getMovesString() -> String {
        piecesManager.moveRecorder.mainBranchRoundsArray().enumerated().map { (index, move) in
            "\(index + 1): \(move)"
        }.joined(separator: " | ")
    }
}

struct Game_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}
