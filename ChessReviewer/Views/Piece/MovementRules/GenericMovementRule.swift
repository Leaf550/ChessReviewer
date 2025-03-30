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
        in piecesLayer: [[PieceViewItem]],
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        var res = [PossibbleMovement]()
        
        iteratePossibleMoves(
            at: position,
            moveMethod: moveMethod
        ) { target in
            let originPiece = getPiece(in: piecesLayer, at: position)
            let targetPiece = getPiece(in: piecesLayer, at: target)
            
            if !threateningCheck {
                let willLeadCheck = CheckChecker.willLeadToCheckedIf(
                    in: piecesLayer,
                    movePiece: originPiece,
                    from: position,
                    to: target
                )
                
                guard !willLeadCheck else {
                    return .leadsToCheck
                }
            }
            
            guard let targetPieceSide = targetPiece.side else {
                res.append(PossibbleMovement(to: target))
                return .blankSquare
            }
            
            if targetPieceSide == side {
                return .blocked
            }
            
            if targetPieceSide != side {
                res.append(PossibbleMovement(to: target, take: targetPiece))
                return .take
            }
            
            return .unknown
        }
        
        return res
    }
}
