//
//  KnightMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct KnightMovementRule: MovementRule {
    var side: PieceViewItem.PieceSide
    private let genericMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        genericMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .offsets([
                (-1, 2), (1, 2), (-2, 1), (-2, -1),
                (2, 1), (2, -1), (1, -2), (-1, -2)
            ])
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewModel]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        return genericMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
    }
}
