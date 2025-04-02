//
//  PiecesLayer.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct PiecesLayer: View {
    @ObservedObject var piecesManager: PiecesManager
    
    private var isPiecesLegal: Bool {
        piecesManager.pieces.count == 8 && piecesManager.pieces.allSatisfy({ $0.count <= 8 })
    }
    
    private func movePiece(from originIndex: BoardIndex, to targetIndex: BoardIndex) {
        guard let targetMovement = (piecesManager.selectedPiecePossibleMovements.first {
            $0.to == targetIndex
        }) else { return }
        piecesManager.movePiece(from: originIndex, to: targetMovement.to)
    }
    
    var body: some View {
        if isPiecesLegal {
            piecesGrid()
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
        } else {
            errorView
        }
    }
        
    private func piecesGrid() -> some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 8) { y in
                HStack(spacing: 0) {
                    ForEach(0 ..< 8) { x in
                        ZStack {
                            let position = BoardIndex(x: x, y: 7 - y)
                            let pieceItem = piecesManager.getPiece(at: position)
                            let isPossibleMove = piecesManager.selectedPiecePossibleMovements.contains { $0.to == position }
                            if (isInCheckKing(pieceItem: pieceItem)) {
                                Circle()
                                .foregroundStyle(Color(hex: "#ff2222"))
                                    .frame(width:  35)
                                    .blur(radius: 5)
                            }
                            EquatableView(
                                content: PieceCell(
                                    pieceItem: pieceItem,
                                    isPossibleMove: isPossibleMove,
                                    position: position
                                ) {
                                    guard piecesManager.currentSide == pieceItem.side else { return }
                                    piecesManager.selectedPieceIndex = position
                                } onMoveIndicatorTapped: {
                                    guard let selectedPieceIndex = piecesManager.selectedPieceIndex else { return }
                                    piecesManager.movePiece(from: selectedPieceIndex, to: position)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var errorView: some View {
        VStack {
            Text("棋子布局异常")
                .font(.headline)
            Text("请检查棋子数组维度")
                .font(.subheadline)
        }
        .foregroundColor(.red)
    }
    
    private func isInCheckKing(pieceItem: PieceViewItem) -> Bool {
        if let sideInCkeck = piecesManager.sideInCheck {
            return pieceItem == .k(sideInCkeck)
        }
        return false
    }
}

struct PiecesLayer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Board()
            PiecesLayer(piecesManager: PiecesManager())
        }
    }
}
