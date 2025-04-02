//
//  CheckChecker.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/30.
//

import Foundation

struct CheckChecker {
    static func isInCheck(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewItem]]) -> Bool {
        for (yIndex, piecesInRow) in piecesLayer.reversed().enumerated() {
            for (xIndex, piece) in piecesInRow.enumerated() {
                if piece.side == side {
                    continue
                }
                
                let possibleMovements = piece.movementRule.possibleMoves(
                    at: BoardIndex(x: xIndex, y: yIndex),
                    in: piecesLayer,
                    canShortCastaling: false,
                    canLongCastaling: false,
                    threateningCheck: true
                )
                
                for possibleMovement in possibleMovements {
                    let targetPiece = getPiece(
                        in: piecesLayer,
                        at: BoardIndex(x: possibleMovement.to.xIndex, y: possibleMovement.to.yIndex)
                    )
                    if targetPiece == .k(side) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    static func isCheckmate(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewItem]]) -> Bool {
        for (yIndex, piecesInRow) in piecesLayer.reversed().enumerated() {
            for (xIndex, piece) in piecesInRow.enumerated() {
                if piece.side != side {
                    continue
                }
                
                let possibleMovements = piece.movementRule.possibleMoves(
                    at: BoardIndex(x: xIndex, y: yIndex),
                    in: piecesLayer,
                    canShortCastaling: false,
                    canLongCastaling: false,
                    threateningCheck: false
                )
                if possibleMovements.count != 0 {
                    return false
                }
            }
        }
        
        return true
    }
    
    static func willLeadToCheckedIf(
        in originPiecesLayer: [[PieceViewItem]],
        movePiece pieceItem: PieceViewItem,
        from originPossition: BoardIndex,
        to targetPosition: BoardIndex
    ) -> Bool {
        guard let side = pieceItem.side else { return false }
        
        var tmpPiecesLayout = originPiecesLayer
        guard (0...7).contains(originPossition.xIndex),
              (0...7).contains(originPossition.yIndex),
              (0...7).contains(targetPosition.xIndex),
              (0...7).contains(targetPosition.yIndex) else {
            return false
        }
        tmpPiecesLayout[7 - originPossition.yIndex][originPossition.xIndex] = .none
        tmpPiecesLayout[7 - targetPosition.yIndex][targetPosition.xIndex] = pieceItem
        
        return isInCheck(for: side, in: tmpPiecesLayout)
    }
    
    private static func getPiece(in piecesLayer: [[PieceViewItem]], at possition: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(possition.xIndex),
              (0...7).contains(possition.yIndex) else {
            return .none
        }
        return piecesLayer[7 - possition.yIndex][possition.xIndex]
    }
}
