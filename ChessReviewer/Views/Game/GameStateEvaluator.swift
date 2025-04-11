//
//  CheckChecker.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/30.
//

import Foundation

struct GameStateEvaluator {
    static func isInCheck(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewModel]]) -> Bool {
        for (yIndex, piecesInRow) in piecesLayer.reversed().enumerated() {
            for (xIndex, piece) in piecesInRow.enumerated() {
                if piece.item.side == side {
                    continue
                }
                
                let possibleMovements = piece.item.movementRule.possibleMoves(
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
    
    static func isCheckmate(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewModel]]) -> Bool {
        guard isInCheck(for: side, in: piecesLayer) else { return false }
        
        if getAllPieceMovementsCount(for: side, in: piecesLayer) == 0 {
            return true
        }
        
        return false
    }
    
    static func willLeadToCheckedIf(
        in originPiecesLayer: [[PieceViewModel]],
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
        let originPiece = tmpPiecesLayout[7 - originPossition.yIndex][originPossition.xIndex]
        var targetPiece = tmpPiecesLayout[7 - targetPosition.yIndex][targetPosition.xIndex]
        if targetPiece.item != .none {
            targetPiece = PieceViewModel(.none)
        }
        tmpPiecesLayout[7 - originPossition.yIndex][originPossition.xIndex] = targetPiece
        tmpPiecesLayout[7 - targetPosition.yIndex][targetPosition.xIndex] = originPiece
        
        return isInCheck(for: side, in: tmpPiecesLayout)
    }
    
    static func isStalemate(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewModel]]) -> Bool {
        guard !isInCheck(for: side, in: piecesLayer) else { return false }
        
        if getAllPieceMovementsCount(for: side, in: piecesLayer) == 0 {
            return true
        }
        
        return false
    }
    
    static func hasThreefoldRepetition(in moveRecorder: MoveRecorder) -> Bool {
        guard let currentMove = moveRecorder.currentMove else { return false }
        
        var ptr = currentMove.previous
        var currentFENCount = 1
        let currentFEN = currentMove.fen
        while ptr != nil {
            if ptr?.fen?.fenWithoutHalfmoveClockAndRoundString()
                == currentFEN?.fenWithoutHalfmoveClockAndRoundString() {
                currentFENCount += 1
            }
            if currentFENCount == 3 {
                return true
            }
            ptr = ptr?.previous
        }
        
        return false
    }
    
    static func willLeadsToImpossibleToCheckmateIf(
        _ side: PieceViewItem.PieceSide,
        promoteTo promotePiece: PieceViewItem,
        in pieces: [[PieceViewModel]]
    ) -> Bool {
        var piecesCount = getPiecesCount(for: side, in: pieces)
        let opponentPiecesCount = getPiecesCount(for: side.opponent, in: pieces)
        
        piecesCount.pawns -= 1
        switch promotePiece {
            case .n(_):
                piecesCount.knights += 1
            case .b(_):
                piecesCount.bishops += 1
            default:
                break
        }
        
        return isImpossibleToCheckmate(forOneSidePiecesCount: piecesCount, andAnotherPiecesCound: opponentPiecesCount)
    }
    
    static func isImpossibleToCheckmate(in pieces: [[PieceViewModel]]) -> Bool {
        let whitePiecesCount = getPiecesCount(for: .white, in: pieces)
        let blackPiecesCount = getPiecesCount(for: .black, in: pieces)
        return isImpossibleToCheckmate(forOneSidePiecesCount: whitePiecesCount, andAnotherPiecesCound: blackPiecesCount)
    }
    
    private struct PiecesCount {
        var pawns: Int = 0
        var rooks: Int = 0
        var knights: Int = 0
        var bishops: Int = 0
        var queens: Int = 0
    }
    
    private static func getPiecesCount(
        for side: PieceViewItem.PieceSide,
        in pieces: [[PieceViewModel]]
    ) -> PiecesCount {
        var count = PiecesCount()
        
        for row in pieces {
            for piece in row {
                switch piece.item {
                    case .p(let pieceSide):
                        if pieceSide == side {
                            count.pawns += 1
                        }
                    case .r(let pieceSide):
                        if pieceSide == side {
                            count.rooks += 1
                        }
                    case .n(let pieceSide):
                        if pieceSide == side {
                            count.knights += 1
                        }
                    case .b(let pieceSide):
                        if pieceSide == side {
                            count.bishops += 1
                        }
                    case .q(let pieceSide):
                        if pieceSide == side {
                            count.queens += 1
                        }
                    default:
                        break
                }
            }
        }
        
        return count
    }
    
    private static func isImpossibleToCheckmate(
        forOneSidePiecesCount piecesCountA: PiecesCount,
        andAnotherPiecesCound piecesCountB: PiecesCount
    ) -> Bool {
        if piecesCountA.pawns != 0 || piecesCountA.rooks != 0 || piecesCountA.queens != 0
            || piecesCountB.pawns != 0 || piecesCountB.rooks != 0 || piecesCountB.queens != 0 {
            return false
        }
        
        let aLight = piecesCountA.knights + piecesCountA.bishops
        let bLight = piecesCountB.knights + piecesCountB.bishops

        // 王对王
        if aLight == 0 && bLight == 0 {
            return true
        }
        
        // 一方仅剩王，另一方有单个轻子
        if (aLight == 0 && bLight == 1) || (bLight == 0 && aLight == 1) {
            return true
        }
        
        // 双方各有一个轻子
        if aLight == 1 && bLight == 1 {
            return true
        }
        
        return false
    }
    
    private static func getPiece(in piecesLayer: [[PieceViewModel]], at possition: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(possition.xIndex),
              (0...7).contains(possition.yIndex) else {
            return .none
        }
        return piecesLayer[7 - possition.yIndex][possition.xIndex].item
    }
    
    private static func getAllPieceMovementsCount(for side: PieceViewItem.PieceSide, in piecesLayer: [[PieceViewModel]]) -> Int {
        var res = 0
        
        for (yIndex, piecesInRow) in piecesLayer.reversed().enumerated() {
            for (xIndex, piece) in piecesInRow.enumerated() {
                if piece.item.side != side {
                    continue
                }
                
                let possibleMovements = piece.item.movementRule.possibleMoves(
                    at: BoardIndex(x: xIndex, y: yIndex),
                    in: piecesLayer,
                    canShortCastaling: false,
                    canLongCastaling: false,
                    threateningCheck: false
                )
                res += possibleMovements.count
            }
        }
        
        return res
    }
}
