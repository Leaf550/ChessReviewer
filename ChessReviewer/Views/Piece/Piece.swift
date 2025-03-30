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
            if pieceViewItem.side != piecesManager.currentSide {
                return
            }
            piecesManager.selectedPieceIndex = position
        } label: {
            ZStack {
                Text(pieceViewItem.pieceNotation)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(pieceViewItem.side == .white ? .white : .black)
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
