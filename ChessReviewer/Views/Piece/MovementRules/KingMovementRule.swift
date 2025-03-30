//
//  KingMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct KingMovementRule: MovementRule {
    var side: PieceViewItem.PieceSide
    private let offsetMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        offsetMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .offsets([
                (-1, 1), (0, 1), (1, 1), (-1, 0),
                (1, 0), (-1, -1), (0, -1), (1, -1)
            ])
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewItem]],
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        return offsetMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
    }
}
