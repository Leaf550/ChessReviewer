//
//  PieceCell.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import SwiftUI

struct PieceCell: View, Equatable {
    let pieceItem: PieceViewItem
    let isPossibleMove: Bool
    let position: BoardIndex
    var onPieceButtonTapped: (() -> Void) = {}
    var onMoveIndicatorTapped: (() -> Void) = {}
    
    var body: some View {
        print("render PieceCell")
        return ZStack {
            switch pieceItem {
                case .none:
                    Color.clear
                        .contentShape(Rectangle())
                        .allowsHitTesting(false)
                default:
                    Piece(
                        pieceViewItem: pieceItem
                    ) {
                        onPieceButtonTapped()
                    }
            }
            
            if isPossibleMove {
                MoveIndicator(targetIndex: position) {
                    onMoveIndicatorTapped()
                }
            }
        }
    }
    
    static func == (lhs: PieceCell, rhs: PieceCell) -> Bool {
        lhs.pieceItem == rhs.pieceItem && lhs.position == rhs.position && lhs.isPossibleMove == rhs.isPossibleMove
    }
}

struct PieceCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PieceCell(
                pieceItem: .r(.white),
                isPossibleMove: true,
                position: BoardIndex.getOriginIndex()
            )
            PieceCell(
                pieceItem: .r(.white),
                isPossibleMove: false,
                position: BoardIndex.getOriginIndex()
            )
        }
        .frame(width: 50, height: 100)
        .background(.blue)
    }
}
