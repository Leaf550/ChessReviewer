//
//  Material.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Piece: View {
    @ObservedObject var piecesManager: PiecesManager
    
    let position: BoardIndex
    var pieceViewItem: PieceViewItem {
        piecesManager.getPiece(at: position)
    }
    
    init(
        position: BoardIndex,
        piecesManager: PiecesManager
    ) {
        self.position = position
        self.piecesManager = piecesManager
    }
    
    var body: some View {
        Button {
            piecesManager.selectedPieceIndex = position
            print("选中了棋子：\(pieceViewItem.pieceCommonName)，位置：\(position.toPositionStr())")
            let piece = piecesManager.getPiece(at: position)
            if piece != .none {
                let moves = pieceViewItem.movementRule.possibleMoves(
                    at: position,
                    in: piecesManager
                )
                print("可移动位置：", moves.map {
                    $0.to.toPositionStr()
                    + ($0.take != nil ? " takes \($0.take?.pieceCommonName ?? "")" : "")
                    + ($0.promotion ? "，升变" : "")
                })
            }
            print("------------------------------------------------")
        } label: {
            ZStack {
                Text(pieceViewItem.pieceNotation)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Material_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BoardCell(cellIndex: BoardIndex.getOriginIndex())
            Piece(position: BoardIndex.getOriginIndex(), piecesManager: PiecesManager())
        }
        .frame(width: 50, height: 50)
    }
}
