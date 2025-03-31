//
//  BishopMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct BishopMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    private let genericMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        genericMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .directionsAndDistance([(-1, 1), (1, 1), (-1, -1), (1, -1)], 7)
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewItem]],
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        genericMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
    }
}
