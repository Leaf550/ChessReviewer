//
//  SlideMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct GenericMovementRule: MovementRule {
    let side: PieceViewItem.PieceSide
    let moveMethod: MoveMethod
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewModel]],
        canShortCastaling: Bool = false,
        canLongCastaling: Bool = false,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        var res = [PossibbleMovement]()
        
        iteratePossibleMoves(
            at: position,
            moveMethod: moveMethod
        ) { target in
            let originPiece = getPiece(in: piecesLayer, at: position)
            let targetPiece = getPiece(in: piecesLayer, at: target)
            
            var possibleCheckResult: MovePossibleCheckResult = .unknown
            
            if targetPiece.side == nil {
                possibleCheckResult = .blankSquare
            } else if let targetPieceSide = targetPiece.side, targetPieceSide == side {
                possibleCheckResult = .blocked
            } else {
                possibleCheckResult = .take
            }
            
            if !threateningCheck && possibleCheckResult != .blocked {
                let willLeadCheck = GameStateEvaluator.willLeadToCheckedIf(
                    in: piecesLayer,
                    movePiece: originPiece,
                    from: position,
                    to: target
                )
                
                if willLeadCheck {
                    return .leadsToCheck
                }
            }
            
            if possibleCheckResult == .blankSquare {
                res.append(PossibbleMovement(to: target))
            } else if possibleCheckResult == .take {
                res.append(PossibbleMovement(to: target, take: targetPiece))
            }
            
            return possibleCheckResult
        }
        
        return res
    }
}
