//
//  PiecesManager.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation
import SwiftUI

struct PieceViewModel: Identifiable {
    var id = UUID()
    var item: PieceViewItem
    
    init(_ item: PieceViewItem) {
        self.item = item
    }
}

class PiecesManager: ObservableObject {
    @Published var moveRecorder: MoveRecorder = MoveRecorder()
    
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
    
    @Published var showPromotionAlert = false
    var promotionSide: PieceViewItem.PieceSide?
    private var promotionPosition: BoardIndex?
    
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
        
        var res: [PossibbleMovement] = []
        
        if currentSide == .white {
            res = selectedPiece.movementRule.possibleMoves(
                at: selectedPieceIndex,
                in: pieces,
                canShortCastaling: canWhiteShortCastling,
                canLongCastaling: canWhiteLongCastling,
                threateningCheck: false
            )
        } else {
            res = selectedPiece.movementRule.possibleMoves(
                at: selectedPieceIndex,
                in: pieces,
                canShortCastaling: canBlackShortCastling,
                canLongCastaling: canBlackLongCastling,
                threateningCheck: false
            )
        }
        
        guard let lastMove = moveRecorder.currentMove else { return res }
        
        switch selectedPiece {
            case .p(let side):
                let enPassantLine = side == .white ? 4 : 3
                let enPassentTargetLine = side == .white ? 5 : 2
                let opponentPawnStartLine = side.opponent == .white ? 1 : 6
                guard selectedPieceIndex.yIndex == enPassantLine else { break }
                guard lastMove.piece == .p(side.opponent) else { break }
                guard lastMove.origin.yIndex == opponentPawnStartLine else { break }
                guard lastMove.target.yIndex == enPassantLine else { break }
                guard lastMove.target.xIndex == selectedPieceIndex.xIndex + 1 || lastMove.target.xIndex == selectedPieceIndex.xIndex - 1 else { break }
                res.append(
                    PossibbleMovement(to: BoardIndex(x: lastMove.target.xIndex, y: enPassentTargetLine), enPassant: true)
                )
            default:
                break
        }
        
        return res
    }
    
    var currentGameStatus: GameStatus {
        GameStatus(
            currentSide: currentSide,
            currentTurn: currentTurn,
            currentRound: currentRound,
            sideInCheck: sideInCheck,
            sideInCheckmate: sideInCheckmate,
            blackARookMoved: blackARookMoved,
            blackHRookMoved: blackHRookMoved,
            blackKingMoved: blackKingMoved,
            whiteARookMoved: whiteARookMoved,
            whiteHRookMoved: whiteHRookMoved,
            whiteKingMoved: whiteKingMoved
        )
    }
    
    @Published var pieces: [[PieceViewModel]] = [
        [
            PieceViewModel(.r(.black)), PieceViewModel(.n(.black)),
            PieceViewModel(.b(.black)), PieceViewModel(.q(.black)),
            PieceViewModel(.k(.black)), PieceViewModel(.b(.black)),
            PieceViewModel(.n(.black)), PieceViewModel(.r(.black))
        ],
        [
            PieceViewModel(.p(.black)), PieceViewModel(.p(.black)),
            PieceViewModel(.p(.black)), PieceViewModel(.p(.black)),
            PieceViewModel(.p(.black)), PieceViewModel(.p(.black)),
            PieceViewModel(.p(.black)), PieceViewModel(.p(.black))
        ],
        [
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none)
        ],
        [
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none)
        ],
        [
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none)
        ],
        [
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none),
            PieceViewModel(.none), PieceViewModel(.none)
        ],
        [
            PieceViewModel(.p(.white)), PieceViewModel(.p(.white)),
            PieceViewModel(.p(.white)), PieceViewModel(.p(.white)),
            PieceViewModel(.p(.white)), PieceViewModel(.p(.white)),
            PieceViewModel(.p(.white)), PieceViewModel(.p(.white))
        ],
        [
            PieceViewModel(.r(.white)), PieceViewModel(.n(.white)),
            PieceViewModel(.b(.white)), PieceViewModel(.q(.white)),
            PieceViewModel(.k(.white)), PieceViewModel(.b(.white)),
            PieceViewModel(.n(.white)), PieceViewModel(.r(.white))
        ],
    ]
    
}

extension PiecesManager {
    func getPiece(at index: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(index.xIndex),
              (0...7).contains(index.yIndex) else {
            return .none
        }
        return pieces[7 - index.yIndex][index.xIndex].item
    }
    
    func movePiece(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex,
        isShortCastaling: Bool = false,
        isLongCastling: Bool = false,
        enPassant: Bool = false
    ) {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else {
            return
        }
        let originPiece = pieces[7 - originIndex.yIndex][originIndex.xIndex]
        var targetPiece = pieces[7 - targetIndex.yIndex][targetIndex.xIndex]
        if targetPiece.item != .none {
            targetPiece = PieceViewModel(.none)
        }
        withAnimation(.easeOut(duration: 0.15)) {
            pieces[7 - originIndex.yIndex][originIndex.xIndex] = targetPiece
            pieces[7 - targetIndex.yIndex][targetIndex.xIndex] = originPiece
        }
        
        if isShortCastaling || isLongCastling {
            moveCastalingRook(isShortCastaling: isShortCastaling, isLongCastling: isLongCastling)
        }
        
        if originPiece.item == .p(.white) && targetIndex.yIndex == 7
            || originPiece.item == .p(.black) && targetIndex.yIndex == 0 {
            promotionPosition = targetIndex
            promotionSide = originPiece.item.side
            showPromotionAlert.toggle()
        }
        
        if enPassant {
            let opponentPawnYIndex = currentSide == .white ? targetIndex.yIndex - 1 : targetIndex.yIndex + 1
            let opponentPawnPosition = BoardIndex(x: targetIndex.xIndex, y: opponentPawnYIndex)
            withAnimation(.easeOut(duration: 0.15)) {
                pieces[7 - opponentPawnPosition.yIndex][opponentPawnPosition.xIndex] = PieceViewModel(.none)
            }
        }
        
        toggleCastlingCondition(movedPiece: originPiece.item, originPosition: originIndex)
        
        if currentSide == sideInCheck {
            sideInCheck = nil
        }
        
        let checkingCheckSide: PieceViewItem.PieceSide = currentSide == PieceViewItem.PieceSide.white ? .black : .white
        toggleCheckStatus(for: checkingCheckSide)
        
        let newMove = Move(
            previous: moveRecorder.currentMove,
            from: originIndex,
            to: targetIndex,
            piece: originPiece.item,
            gameStatus: currentGameStatus,
            currentPiecesLayout: pieces
        )
        
        if moveRecorder.currentMove == nil {
            moveRecorder.currentMove = newMove
            moveRecorder.timeline = moveRecorder.currentMove
        } else {
            moveRecorder.currentMove?.next = newMove
            moveRecorder.currentMove = moveRecorder.currentMove?.next
        }
        
        if currentSide == PieceViewItem.PieceSide.black {
            currentRound += 1
        }
        currentSide = currentSide == PieceViewItem.PieceSide.white ? .black : .white
        currentTurn += 1
    }
    
    func promotion(to piece: PieceViewItem) {
        guard let promotionPosition = promotionPosition else { return }
        pieces[7 - promotionPosition.yIndex][promotionPosition.xIndex] = PieceViewModel(piece)
        
        toggleCheckStatus(for: currentSide)
        
        moveRecorder.currentMove?.promotion = piece
        
        self.promotionPosition = nil
        promotionSide = nil
    }
    
    private func toggleCheckStatus(for side: PieceViewItem.PieceSide) {
        if CheckChecker.isInCheck(
            for: side,
            in: pieces
        ) {
            sideInCheck = side
            moveRecorder.currentMove?.gameStatus.sideInCheck = side
            if CheckChecker.isCheckmate(
                for: side,
                in: pieces
            ) {
                sideInCheckmate = side
                moveRecorder.currentMove?.gameStatus.sideInCheckmate = side
            }
        }
    }
    
    private func moveCastalingRook(
        isShortCastaling: Bool,
        isLongCastling: Bool
    ) {
        var rookPosition = BoardIndex.getOriginIndex()
        var rookTarget = BoardIndex.getOriginIndex()
        
        switch currentSide {
            case.white:
                if isLongCastling {
                    rookPosition = BoardIndex(x: 0, y: 0)
                    rookTarget = BoardIndex(x: 3, y: 0)
                } else {
                    rookPosition = BoardIndex(x: 7, y: 0)
                    rookTarget = BoardIndex(x: 5, y: 0)
                }
            case .black:
                if isLongCastling {
                    rookPosition = BoardIndex(x: 0, y: 7)
                    rookTarget = BoardIndex(x: 3, y: 7)
                } else {
                    rookPosition = BoardIndex(x: 7, y: 7)
                    rookTarget = BoardIndex(x: 5, y: 7)
                }
        }
        withAnimation(.easeOut(duration: 0.15)) { [weak self] in
            guard let rookItemModel = self?.pieces[7 - rookPosition.yIndex][rookPosition.xIndex] else { return }
            self?.pieces[7 - rookPosition.yIndex][rookPosition.xIndex] = PieceViewModel(.none)
            self?.pieces[7 - rookTarget.yIndex][rookTarget.xIndex] = rookItemModel
        }
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
