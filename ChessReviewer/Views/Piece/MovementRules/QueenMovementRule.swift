//
//  QueenMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct QueenMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    private let genericMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        genericMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .directionsAndDistance([
                (0, 1), (0, -1), (-1, 0), (1, 0),
                (-1, 1), (1, 1), (-1, -1), (1, -1)
            ], 7)
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewItem]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        genericMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
    }
}
