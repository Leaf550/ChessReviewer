//
//  PieceCell.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import SwiftUI

struct PieceCell: View {
    @ObservedObject var manager: PiecesManager

    let position: BoardIndex
    var pieceItem: PieceViewItem {
        manager.getPiece(at: position)
    }
    
    private var isPossibleMove: Bool {
        manager.selectedPiecePossibleMovements.contains { $0.to == position }
    }
    
    var body: some View {
        ZStack {
            switch pieceItem {
                case .none:
                    Color.clear
                        .contentShape(Rectangle())
                        .allowsHitTesting(false)
                default:
                    Piece(
                        position: position,
                        piecesManager: manager
                    )
            }
            
            if isPossibleMove {
                MoveIndicator(manager: manager, targetIndex: position)
            }
        }
    }
}

struct PieceCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PieceCell(manager: PiecesManager(), position: BoardIndex.getOriginIndex())
        }
        .frame(width: 200, height: 200)
        .background(.blue)
    }
}
