//
//  BishopMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct BishopMovementRule: MovementRule {
    var side: PieceViewItem.PieceSide
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        var res: [PossibbleMovement] = []
        
        let bishopMoveDirections = [(-1, 1), (1, 1), (-1, -1), (1, -1)]
        let bishopMoveMaxDistance = 7
        
        iteratePossibleMoves(
            at: position,
            moveMethod: .directionsAndDistance(bishopMoveDirections, bishopMoveMaxDistance)) { target in
                let targetPiece = pieceManager.getPiece(at: target)
                
                guard let targetPieceSide = targetPiece.side else {
                    res.append(PossibbleMovement(to: target))
                    return MovePossibleCheckResult(couldMove: true, take: false)
                }
                
                if targetPieceSide == side {
                    return MovePossibleCheckResult(couldMove: false, take: false)
                }
                
                if targetPieceSide != side {
                    res.append(PossibbleMovement(to: target, take: targetPiece))
                    return MovePossibleCheckResult(couldMove: true, take: true)
                }
                
                return MovePossibleCheckResult(couldMove: false, take: false)
            }
        
        return res
    }
}
