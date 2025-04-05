//
//  KingMovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

struct KingMovementRule: MovementRule {
    var side: PieceViewItem.PieceSide
    private let genericMovementRule: GenericMovementRule
    
    init(side: PieceViewItem.PieceSide) {
        self.side = side
        genericMovementRule = GenericMovementRule(
            side: side,
            moveMethod: .offsets([
                (-1, 1), (0, 1), (1, 1), (-1, 0),
                (1, 0), (-1, -1), (0, -1), (1, -1)
            ])
        )
    }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewModel]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        var res: [PossibbleMovement] = []
        res.append(
            contentsOf: genericMovementRule.possibleMoves(at: position, in: piecesLayer, threateningCheck: threateningCheck)
        )
        
        if canShortCastaling {
            var shortCastalingMoves: [PossibbleMovement] = []
            
            iteratePossibleMoves(
                at: position,
                moveMethod: .directionsAndDistance([(1, 0)], 2)
            ) { targetPosition in
                let originPiece = getPiece(in: piecesLayer, at: position)
                let targetPiece = getPiece(in: piecesLayer, at: targetPosition)
                
                var possibleCheckResult: MovePossibleCheckResult = .unknown
                
                if targetPiece.side == nil {
                    possibleCheckResult = .blankSquare
                } else {
                    possibleCheckResult = .blocked
                }
                
                if !threateningCheck && possibleCheckResult != .blocked {
                    let willLeadCheck = CheckChecker.willLeadToCheckedIf(
                        in: piecesLayer,
                        movePiece: originPiece,
                        from: position,
                        to: targetPosition
                    )
                    
                    if willLeadCheck {
                        return .blocked
                    }
                }
                
                if possibleCheckResult == .blankSquare {
                    shortCastalingMoves.append(PossibbleMovement(to: targetPosition))
                }
                
                return possibleCheckResult
            }
            
            if shortCastalingMoves.count == 2 {
                res.append(PossibbleMovement(to: shortCastalingMoves[1].to, shortCastaling: true))
            }
        }
        
        let bPiece = getPiece(
            in: piecesLayer,
            at: BoardIndex(x: 1, y: side == .white ? 0 : 7)
        )
        
        if canLongCastaling && bPiece == .none {
            var longCastalingMoves: [PossibbleMovement] = []
            
            iteratePossibleMoves(
                at: position,
                moveMethod: .directionsAndDistance([(-1, 0)], 2)
            ) { targetPosition in
                let originPiece = getPiece(in: piecesLayer, at: position)
                let targetPiece = getPiece(in: piecesLayer, at: targetPosition)
                
                var possibleCheckResult: MovePossibleCheckResult = .unknown
                
                if targetPiece.side == nil {
                    possibleCheckResult = .blankSquare
                } else {
                    possibleCheckResult = .blocked
                }
                
                if !threateningCheck && possibleCheckResult != .blocked {
                    let willLeadCheck = CheckChecker.willLeadToCheckedIf(
                        in: piecesLayer,
                        movePiece: originPiece,
                        from: position,
                        to: targetPosition
                    )
                    
                    if willLeadCheck {
                        return .blocked
                    }
                }
                
                if possibleCheckResult == .blankSquare {
                    longCastalingMoves.append(PossibbleMovement(to: targetPosition))
                }
                
                return possibleCheckResult
            }
            
            if longCastalingMoves.count == 2 {
                res.append(PossibbleMovement(to: longCastalingMoves[1].to, longCastaling: true))
            }
        }
        
        return res
    }
}
