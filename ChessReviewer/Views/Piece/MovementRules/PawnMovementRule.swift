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
        in piecesLayer: [[PieceViewItem]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        var res: [PossibbleMovement] = []
        
        let startLine = side == .white ? 1 : 6
        let yDirection = side == .white ? 1 : -1
        
        // 普通移动
        let plainMoveDirection = side == .white ? [(0, 1)] : [(0, -1)]
        var plainMoveMaxDistance = 1
        
        if position.yIndex == startLine {
            plainMoveMaxDistance = 2
        }
        
        iteratePossibleMoves(
            at: position,
            moveMethod: .directionsAndDistance(plainMoveDirection, plainMoveMaxDistance)
        ) { target in
            let targetPiece = getPiece(in: piecesLayer, at: target)
            
            var possibleCheckResult: MovePossibleCheckResult = .unknown
            
            if targetPiece.side == nil {
                possibleCheckResult = .blankSquare
            } else {
                possibleCheckResult = .blocked
            }
            
            if !threateningCheck && possibleCheckResult != .blocked {
                let willLeadCheck = CheckChecker.willLeadToCheckedIf(
                    in: piecesLayer,
                    movePiece: .p(side),
                    from: position,
                    to: target
                )
                
                guard !willLeadCheck else {
                    return .leadsToCheck
                }
            }
            
            if possibleCheckResult == .blankSquare {
                res.append(PossibbleMovement(to: target))
            }
            
            return possibleCheckResult
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
            let targetPiece = getPiece(in: piecesLayer, at: target)
            
            var possibleCheckResult: MovePossibleCheckResult = .unknown
            
            if targetPiece == .none {
                possibleCheckResult = .unknown
            } else if targetPiece.side != side {
                possibleCheckResult = .take
            }
            
            if !threateningCheck && possibleCheckResult == .take {
                let willLeadCheck = CheckChecker.willLeadToCheckedIf(
                    in: piecesLayer,
                    movePiece: .p(side),
                    from: position,
                    to: target
                )
                
                guard !willLeadCheck else {
                    return .leadsToCheck
                }
            }
            
            if possibleCheckResult == .take {
                res.append(PossibbleMovement(to: target, take: targetPiece))
            }
            
            return possibleCheckResult
        }
        
        return res
    }
}
