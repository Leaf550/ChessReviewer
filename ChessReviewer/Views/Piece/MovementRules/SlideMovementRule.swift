//
//  SlideMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct SlideMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    let directions: [(Int, Int)]
    let maxDistance: Int
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        if pieceManager.currentSide != side {
            return []
        }
        
        var res = [PossibbleMovement]()
        
        iteratePossibleMoves(
            at: position,
            moveMethod: .directionsAndDistance(directions, maxDistance)
        ) { target in
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
