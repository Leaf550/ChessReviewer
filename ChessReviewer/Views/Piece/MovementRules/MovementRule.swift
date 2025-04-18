//
//  MovementRule.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import Foundation

struct PossibbleMovement {
    var to: BoardIndex
    var take: PieceViewItem? = nil
    var check: Bool = false
    var promotion: Bool = false
}

protocol MovementRule {
    var side: PieceViewItem.PieceSide { get }
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement]
}

enum MoveMethod {
    // 棋子按某个方向、指定最大距离行棋，例如车、后、象
    case directionsAndDistance([(Int, Int)], Int)
    // 棋子在一些可能的格子内行棋，例如🐴、兵吃子、王。
    case offsets([(Int, Int)])
}

struct MovePossibleCheckResult {
    var couldMove: Bool
    var take: Bool
}

extension MovementRule {
    func iteratePossibleMoves(
        at position: BoardIndex,
        moveMethod: MoveMethod,
        checkPossible: (BoardIndex) -> MovePossibleCheckResult
    ) {
        switch moveMethod {
            case .directionsAndDistance(let directions, let distance):
                for direction in directions {
                    for step in 1 ... distance {
                        let targetX = position.xIndex + direction.0 * step
                        let targetY = position.yIndex + direction.1 * step
                        if !((0...7).contains(targetX) && (0...7).contains(targetY)) {
                            break
                        }
                        
                        let target = BoardIndex(x: targetX, y: targetY)
                        let checkResult = checkPossible(target)
                        if checkResult.take {
                            break
                        }
                        if !checkResult.couldMove {
                            break
                        }
                    }
                }
            case .offsets(let offsets):
                for offset in offsets {
                    let targetX = position.xIndex + offset.0
                    let targetY = position.yIndex + offset.1
                    if !((0...7).contains(targetX) && (0...7).contains(targetY)) {
                        break
                    }
                    
                    let target = BoardIndex(x: targetX, y: targetY)
                    _ = checkPossible(target)
                }
        }
    }
}

struct EmptyMovement: MovementRule {
    let side: PieceViewItem.PieceSide
    
    func possibleMoves(
        at position: BoardIndex,
        in pieceManager: PiecesManager
    ) -> [PossibbleMovement] {
        return []
    }
}

extension PieceViewItem {
    var movementRule: MovementRule {
        switch self {
            case .p(let side): return PawnMovementRule(side: side)
            case .r(let side): return RookMovementRule(side: side)
            case .n(let side): return EmptyMovement(side: side)
            case .b(let side): return BishopMovementRule(side: side)
            case .q(let side): return EmptyMovement(side: side)
            case .k(let side): return EmptyMovement(side: side)
            case .none: return EmptyMovement(side: .white)
        }
    }
}
