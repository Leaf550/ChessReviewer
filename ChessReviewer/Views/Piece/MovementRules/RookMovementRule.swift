//
//  RookMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct RookMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    private let slideMovementRule: SlideMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        slideMovementRule = SlideMovementRule(
            side: side,
            directions: [(0, 1), (0, -1), (-1, 0), (1, 0)],
            maxDistance: 7
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        slideMovementRule.possibleMoves(at: position, in: pieceManager)
    }
}
