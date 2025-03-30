//
//  RookMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct RookMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    private let slideMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        slideMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .directionsAndDistance([(0, 1), (0, -1), (-1, 0), (1, 0)], 7)
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewItem]],
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        slideMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
    }
}
