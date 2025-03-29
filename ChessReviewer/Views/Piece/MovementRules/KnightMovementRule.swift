//
//  KnightMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct KnightMovementRule: MovementRule {
    var side: PieceViewItem.PieceSide
    private let offsetMovementRule: OffsetMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        offsetMovementRule = OffsetMovementRule(
            side: side,
            offsets: [
                (-1, 2), (1, 2), (-2, 1), (-2, -1),
                (2, 1), (2, -1), (1, -2), (-1, -2)
            ]
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        return offsetMovementRule.possibleMoves(at: position, in: pieceManager)
    }
}
