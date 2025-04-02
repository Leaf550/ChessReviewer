//
//  PiecesManager.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

class PiecesManager: ObservableObject {
    @Published var moveRecorder: MoveRecorder = MoveRecorder()
    var currentMove: Move?
    
    var currentSide = PieceViewItem.PieceSide.white
    var currentTurn = 1
    var currentRound = 1
    
    @Published var sideInCheck: PieceViewItem.PieceSide?
    @Published var sideInCheckmate: PieceViewItem.PieceSide?
    
    var blackARookMoved: Bool = false
    var blackHRookMoved: Bool = false
    var blackKingMoved: Bool = false
    
    var whiteARookMoved: Bool = false
    var whiteHRookMoved: Bool = false
    var whiteKingMoved: Bool = false
    
    var canWhiteShortCastling: Bool {
        sideInCheck != .white && !whiteHRookMoved && !whiteKingMoved
    }
    
    var canWhiteLongCastling: Bool {
        sideInCheck != .white && !whiteARookMoved && !whiteKingMoved
    }
    
    var canBlackShortCastling: Bool {
        sideInCheck != .black && !blackHRookMoved && !blackKingMoved
    }
    
    var canBlackLongCastling: Bool {
        sideInCheck != .black && !blackARookMoved && !blackKingMoved
    }
    
    @Published var selectedPieceIndex: BoardIndex?
    
    var selectedPiece: PieceViewItem? {
        guard let selectedPieceIndex = selectedPieceIndex else { return nil }
        let selected = getPiece(at: selectedPieceIndex)
        guard selected != .none else { return nil }
        return selected
    }
    
    var selectedPiecePossibleMovements: [PossibbleMovement] {
        guard let selectedPieceIndex = selectedPieceIndex else { return [] }
        guard let selectedPiece = selectedPiece  else { return [] }
        
        if currentSide == .white {
            return selectedPiece.movementRule.possibleMoves(
                at: selectedPieceIndex,
                in: pieces,
                canShortCastaling: canWhiteShortCastling,
                canLongCastaling: canWhiteLongCastling,
                threateningCheck: false
            )
        } else {
            return selectedPiece.movementRule.possibleMoves(
                at: selectedPieceIndex,
                in: pieces,
                canShortCastaling: canBlackShortCastling,
                canLongCastaling: canBlackLongCastling,
                threateningCheck: false
            )
        }
    }
    
    @Published var pieces: [[PieceViewItem]] = [
        [
            .r(.black), .n(.black), .b(.black), .q(.black),
            .k(.black), .b(.black), .n(.black), .r(.black)
        ],
        [PieceViewItem](repeating: .p(.black), count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .p(.white), count: 8),
        [
            .r(.white), .n(.white), .b(.white), .q(.white),
            .k(.white), .b(.white), .n(.white), .r(.white)
        ],
    ]
    
}

extension PiecesManager {
    func getPiece(at index: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(index.xIndex),
              (0...7).contains(index.yIndex) else {
            return .none
        }
        return pieces[7 - index.yIndex][index.xIndex]
    }
    
    func movePiece(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex,
        isShortCastaling: Bool = false,
        isLongCastling: Bool = false
    ) {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else {
            return
        }
        let originPiece = getPiece(at: originIndex)
        pieces[7 - originIndex.yIndex][originIndex.xIndex] = .none
        pieces[7 - targetIndex.yIndex][targetIndex.xIndex] = originPiece
        
        if isShortCastaling || isLongCastling {
            moveCastalingRook(isShortCastaling: isShortCastaling, isLongCastling: isLongCastling)
        }
        
        toggleCastlingCondition(movedPiece: originPiece, originPosition: originIndex)
        
        if currentSide == sideInCheck {
            sideInCheck = nil
        }
        
        let checkingCheckSide: PieceViewItem.PieceSide = currentSide == PieceViewItem.PieceSide.white ? .black : .white
        if CheckChecker.isInCheck(
            for: checkingCheckSide,
            in: pieces
        ) {
            sideInCheck = checkingCheckSide
            if CheckChecker.isCheckmate(
                for: checkingCheckSide,
                in: pieces
            ) {
                sideInCheckmate = checkingCheckSide
            }
        }
        
        let newMove = Move(
            previous: currentMove,
            turn: currentTurn,
            round: currentRound,
            from: originIndex,
            to: targetIndex,
            side: currentSide,
            currentPiecesLayout: pieces
        )
        
        if currentMove == nil {
            currentMove = newMove
            moveRecorder.timeline = currentMove
        } else {
            currentMove?.next = newMove
            currentMove = currentMove?.next
        }
        
        if currentSide == PieceViewItem.PieceSide.black {
            currentRound += 1
        }
        currentSide = currentSide == PieceViewItem.PieceSide.white ? .black : .white
        currentTurn += 1
    }
    
    private func moveCastalingRook(
        isShortCastaling: Bool,
        isLongCastling: Bool
    ) {
        var rookPosition = BoardIndex.getOriginIndex()
        var rookTarget = BoardIndex.getOriginIndex()
        var rootTargetPositionPiece: PieceViewItem
        
        switch currentSide {
            case.white:
                if isLongCastling {
                    rookPosition = BoardIndex(x: 0, y: 0)
                    rookTarget = BoardIndex(x: 3, y: 0)
                } else {
                    rookPosition = BoardIndex(x: 7, y: 0)
                    rookTarget = BoardIndex(x: 5, y: 0)
                }
                rootTargetPositionPiece = .r(.white)
            case .black:
                if isLongCastling {
                    rookPosition = BoardIndex(x: 0, y: 7)
                    rookTarget = BoardIndex(x: 3, y: 7)
                } else {
                    rookPosition = BoardIndex(x: 7, y: 7)
                    rookTarget = BoardIndex(x: 5, y: 7)
                }
                rootTargetPositionPiece = .r(.black)
        }
        
        pieces[7 - rookPosition.yIndex][rookPosition.xIndex] = .none
        pieces[7 - rookTarget.yIndex][rookTarget.xIndex] = rootTargetPositionPiece
    }
    
    private func toggleCastlingCondition(movedPiece: PieceViewItem, originPosition: BoardIndex) {
        switch movedPiece {
            case .r(let pieceSide):
                if pieceSide == .white && originPosition.xIndex == 0 {
                    whiteARookMoved = true
                }
                if pieceSide == .black && originPosition.xIndex == 7 {
                    whiteHRookMoved = true
                }
                if pieceSide == .black && originPosition.xIndex == 0 {
                    blackARookMoved = true
                }
                if pieceSide == .black && originPosition.xIndex == 7 {
                    blackHRookMoved = true
                }
            case .k(let pieceSide):
                if pieceSide == .white {
                    whiteKingMoved = true
                } else {
                    blackKingMoved = true
                }
            default:
                break
        }
    }
}

extension PiecesManager {
    
}
