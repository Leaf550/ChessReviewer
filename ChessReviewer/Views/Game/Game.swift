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
            Text(getCheckmateTitle())
                .frame(height: 20)
            Text(getCheckTitle())
                .frame(height: 20)
            ScrollView(.horizontal, showsIndicators: false) {
                Text(getMovesString())
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(height: 20)
            .padding([.leading, .trailing], 20)
            ZStack {
                Board() { _ in 
                    piecesManager.selectedPieceIndex = nil
                }
                PiecesLayer(piecesManager: piecesManager)
            }
            .padding()
        }
        .alert("升变！", isPresented: $piecesManager.showPromotionAlert) {
            Button("车", role: .none) {
                guard let promotionSide = piecesManager.promotionSide else { return }
                piecesManager.promotion(to: .r(promotionSide))
            }
            Button("马", role: .none) {
                guard let promotionSide = piecesManager.promotionSide else { return }
                piecesManager.promotion(to: .n(promotionSide))
            }
            Button("象", role: .none) {
                guard let promotionSide = piecesManager.promotionSide else { return }
                piecesManager.promotion(to: .b(promotionSide))
            }
            Button("后", role: .none) {
                guard let promotionSide = piecesManager.promotionSide else { return }
                piecesManager.promotion(to: .q(promotionSide))
            }
        }
    }
    
    private func getCheckmateTitle() -> String {
        if let sideInCheckmate = piecesManager.sideInCheckmate {
            return "Chackmate to \(sideInCheckmate == .white ? "white" : "black")!"
        }
        return ""
    }
    
    private func getCheckTitle() -> String {
        if let sideInCheck = piecesManager.sideInCheck {
            return "Chack to \(sideInCheck == .white ? "white" : "black")!"
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
