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
            if (isInCheckKing()) {
                Circle()
                .foregroundStyle(Color(hex: "#ff3333"))
                    .frame(width:  35)
                    .blur(radius: 5)
            }
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
    
    private func isInCheckKing() -> Bool {
        if let sideInCkeck = manager.sideInCheck {
            return pieceItem == .k(sideInCkeck)
        }
        return false
    }
}

struct PieceCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PieceCell(manager: PiecesManager(), position: BoardIndex(x: 4, y: 0))
        }
        .frame(width: 50, height: 50)
        .background(.blue)
    }
}
