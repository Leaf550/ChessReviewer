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
    var shortCastaling: Bool = false
    var longCastaling: Bool = false
    var enPassant: Bool = false
}

protocol MovementRule {
    var side: PieceViewItem.PieceSide { get }
    
    func possibleMoves(
        at position: BoardIndex,
        in piecesLayer: [[PieceViewModel]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement]
}

enum MoveMethod {
    // 棋子按某个方向、指定最大距离行棋，例如车、后、象
    case directionsAndDistance([(Int, Int)], Int)
    // 棋子在一些可能的格子内行棋，例如🐴、兵吃子、王。
    case offsets([(Int, Int)])
}

enum MovePossibleCheckResult {
    case blocked
    case leadsToCheck
    case blankSquare
    case take
    case unknown
}

extension MovementRule {
    func getPiece(in piecesLayer: [[PieceViewModel]], at possition: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(possition.xIndex),
              (0...7).contains(possition.yIndex) else {
            return .none
        }
        return piecesLayer[7 - possition.yIndex][possition.xIndex].item
    }
    
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
                        
                        if checkResult == .blocked {
                            break
                        } else if checkResult == .leadsToCheck {
                            continue
                        } else if checkResult == .blankSquare {
                            continue
                        } else if checkResult == .take {
                            break
                        } else {
                            break
                        }
                    }
                }
            case .offsets(let offsets):
                for offset in offsets {
                    let targetX = position.xIndex + offset.0
                    let targetY = position.yIndex + offset.1
                    if !((0...7).contains(targetX) && (0...7).contains(targetY)) {
                        continue
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
        in piecesLayer: [[PieceViewModel]],
        canShortCastaling: Bool,
        canLongCastaling: Bool,
        threateningCheck: Bool
    ) -> [PossibbleMovement] {
        return []
    }
}

extension PieceViewItem {
    var movementRule: MovementRule {
        switch self {
            case .p(let side): return PawnMovementRule(side: side)
            case .r(let side): return RookMovementRule(side: side)
            case .n(let side): return KnightMovementRule(side: side)
            case .b(let side): return BishopMovementRule(side: side)
            case .q(let side): return QueenMovementRule(side: side)
            case .k(let side): return KingMovementRule(side: side)
            case .none: return EmptyMovement(side: .white)
        }
    }
}
