//
//  PawnMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import Foundation

struct PawnMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        var res: [PossibbleMovement] = []
        
        let startLine = side == .white ? 1 : 6
        let promotionLine = side == .white ? 7 : 0
        let yDirection = side == .white ? 1 : -1
        
        // 普通移动
        var plainMoveOffsets: [(Int, Int)] = []
        
        plainMoveOffsets.append((0, 1 * yDirection))
        if position.yIndex == startLine {
            plainMoveOffsets.append((0, 2 * yDirection))
        }

        iteratePossibleMoves(
            at: position,
            moveMethod: .offsets(plainMoveOffsets)
        ) { target in
            let targetPiece = pieceManager.getPiece(at: target)
            
            if targetPiece == .none {
                res.append(PossibbleMovement(to: target, promotion: target.yIndex == promotionLine))
                return MovePossibleCheckResult(couldMove: true, take: false)
            }
            
            return MovePossibleCheckResult(couldMove: false, take: false)
        }
        
        // 吃子
        let takesMoveOffsets: [(Int, Int)] = [
            (-1, yDirection),
            (1, yDirection)
        ]
        iteratePossibleMoves(
            at: position,
            moveMethod: .offsets(takesMoveOffsets)
        ) { target in
            let targetPiece = pieceManager.getPiece(at: target)
            
            if targetPiece == .none {
                return MovePossibleCheckResult(couldMove: false, take: false)
            }
            
            if targetPiece.side != side {
                res.append(PossibbleMovement(to: target, take: targetPiece))
                return MovePossibleCheckResult(couldMove: true, take: true)
            }
            
            return MovePossibleCheckResult(couldMove: false, take: false)
        }
        
        return res
    }
}
