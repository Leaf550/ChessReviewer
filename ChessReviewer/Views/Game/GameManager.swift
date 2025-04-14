//
//  GameManager.swift
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

class GameManager: ObservableObject {
    var gameBuilder: InitialGameBuilder
    
    var engine: UCIEngine?
    
    @Published var moveRecorder: MoveRecorder = MoveRecorder()
    
    @Published var pieces: [[PieceViewModel]]
    
    var currentSide: PieceViewItem.PieceSide
    var currentTurn = 1
    var currentRound = 1
    var turnsAfterTakenOrPawnMoved = 0
    
    var blackARookMoved: Bool = false
    var blackHRookMoved: Bool = false
    var blackKingMoved: Bool = false
    
    var whiteARookMoved: Bool = false
    var whiteHRookMoved: Bool = false
    var whiteKingMoved: Bool = false
    
    // 1. 如果 gameBuilder（局面初始状态）规定在初始状态时就已经不能易位，则直接返回false。
    // 2. 如果 gameBuilder 规定在初始状态时能易位，则检查车和王是否在原位，以及是否被将军，以防用户错误设置。
    // 3. 除了检查车和王是否在原位，还要检查王和车是否移动过。
    // 4. 四个车和两个王是否移动过无论是用户设置的局面还是标准初始局面默认都为否，因此在初始局面的情况下这两条始终满足。
    // 5. 如果后续车和王移动过（6个是否移动的标记位会在 `movePiece` 函数中修改），或者不在原位，则不能易位。
    // 6. 易位的其他条件：王和车是否被阻挡、王的移动路径是否被威胁会在 `movementRule.possibleMoves` 函数中检查。
    var canWhiteShortCastling: Bool {
        gameBuilder.canWhiteShortCastling ? (
            sideInCheck != .white
            && getPiece(at: BoardIndex(x: 7, y: 0)) == .r(.white)
            && getPiece(at: BoardIndex(x: 4, y: 0)) == .k(.white)
            && !whiteHRookMoved
            && !whiteKingMoved
        ) : false
    }
    
    var canWhiteLongCastling: Bool {
        gameBuilder.canWhiteLongCastling ? (
            sideInCheck != .white
            && getPiece(at: BoardIndex(x: 0, y: 0)) == .r(.white)
            && getPiece(at: BoardIndex(x: 4, y: 0)) == .k(.white)
            && !whiteARookMoved
            && !whiteKingMoved
        ) : false
    }
    
    var canBlackShortCastling: Bool {
        gameBuilder.canBlackShortCastling ? (
            sideInCheck != .black
            && getPiece(at: BoardIndex(x: 7, y: 7)) == .r(.black)
            && getPiece(at: BoardIndex(x: 4, y: 7)) == .k(.black)
            && !blackHRookMoved
            && !blackKingMoved
        ) : false
    }
    
    var canBlackLongCastling: Bool {
        gameBuilder.canBlackLongCastling ? (
            sideInCheck != .black
            && getPiece(at: BoardIndex(x: 0, y: 7)) == .r(.black)
            && getPiece(at: BoardIndex(x: 4, y: 7)) == .k(.black)
            && !blackARookMoved
            && !blackKingMoved
        ) : false
    }
    
    @Published var showPromotionAlert = false
    @Published var canPromoteToKnight = true
    @Published var canPromoteToBishop = true
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
        guard !gameOver else { return [] }
        guard let selectedPieceIndex = selectedPieceIndex else { return [] }
        guard let selectedPiece = selectedPiece  else { return [] }
        
        var res: [PossibbleMovement] = []
        
        res = selectedPiece.movementRule.possibleMoves(
            at: selectedPieceIndex,
            in: pieces,
            canShortCastaling: currentSide == .white ? canWhiteShortCastling : canBlackShortCastling,
            canLongCastaling: currentSide == .white ? canWhiteLongCastling : canBlackLongCastling,
            threateningCheck: false
        )
        
        if let enPassantMove = enPassantMoveTarget(for: selectedPiece, at: selectedPieceIndex) {
            res.append(PossibbleMovement(to: enPassantMove, enPassant: true))
        }
        
        return res
    }
    
    @Published var sideInCheck: PieceViewItem.PieceSide?
    @Published var sideInCheckmate: PieceViewItem.PieceSide?
    @Published var sideInStalemate: PieceViewItem.PieceSide?
    @Published var threefoldRepetition: Bool = false
    @Published var impossibleToCheckmate: Bool = false
    
    var gameOver: Bool {
        sideInCheckmate != nil || threefoldRepetition || impossibleToCheckmate
    }
    
    var isReviewingHistory: Bool = false
    
    init?(gameBuilder: InitialGameBuilder) {
        self.gameBuilder = gameBuilder
        self.pieces = gameBuilder.pieces
        self.currentSide = gameBuilder.currentMoveSide
        
        self.engine = UCIEngine { [weak self] from, to in
            self?.movePiece(from: from, to: to)
        }
        
        self.toggleCheckStatus(for: .white)
        let isWhiteInCheck = sideInCheck == .white
        self.toggleCheckStatus(for: .black)
        let isBlackInCheck = sideInCheck == .black
        
        if isWhiteInCheck && isBlackInCheck {
            return nil
        }
        
        self.toggleStalemateStatus(for: .white)
        let isWhiteInStalemate = sideInStalemate == .white
        self.toggleStalemateStatus(for: .black)
        let isBlackInStalemate = sideInStalemate == .black
        
        if isWhiteInStalemate && isBlackInStalemate {
            return nil
        }
        
        impossibleToCheckmate = GameStateEvaluator.isImpossibleToCheckmate(in: self.pieces)
        
        moveRecorder.initialPosition = Move(
            from: BoardIndex.getOriginIndex(),
            to: BoardIndex.getOriginIndex(),
            piece: .none,
            moveRound: 0,
            gameStatus: gameStatusAfterMove(sideAfterMove: gameBuilder.currentMoveSide, round: 1, turn: 1),
            fen: FEN.fromInitialGameBuilder(gameBuilder),
            currentPiecesLayout: gameBuilder.pieces
        )
    }
}

extension GameManager {
    func getPiece(at index: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(index.xIndex),
              (0...7).contains(index.yIndex) else {
            return .none
        }
        return pieces[7 - index.yIndex][index.xIndex].item
    }
    
    func movePiece(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex
    ) {
        guard !gameOver else { return }
        
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else { return }
        
        selectedPieceIndex = nil
        
        let isShortCastaling = moveIsShortCastaling(from: originIndex, to: targetIndex)
        let isLongCastling = moveIsLongCastaling(from: originIndex, to: targetIndex)
        let enPassant = moveIsEnPassant(from: originIndex, to: targetIndex)
        
        let originPiece = pieces[7 - originIndex.yIndex][originIndex.xIndex]
        var targetPiece = pieces[7 - targetIndex.yIndex][targetIndex.xIndex]
        
        // take
        if targetPiece.item != .none {
            targetPiece = PieceViewModel(.none)
        }
        
        if targetPiece.item != .none || originPiece.item == .p(.white) || originPiece.item == .p(.black) {
            turnsAfterTakenOrPawnMoved = 0
        } else {
            turnsAfterTakenOrPawnMoved += 1
        }
        
        // move piece
        withAnimation(.easeOut(duration: 0.15)) {
            pieces[7 - originIndex.yIndex][originIndex.xIndex] = targetPiece
            pieces[7 - targetIndex.yIndex][targetIndex.xIndex] = originPiece
        }
        
        // castaling
        if isShortCastaling || isLongCastling {
            moveCastalingRook(isShortCastaling: isShortCastaling, isLongCastling: isLongCastling)
        }
        
        // pormotion
        if originPiece.item == .p(.white) && targetIndex.yIndex == 7
            || originPiece.item == .p(.black) && targetIndex.yIndex == 0 {
            promotionPosition = targetIndex
            promotionSide = originPiece.item.side
            
            canPromoteToKnight = !GameStateEvaluator.willLeadsToImpossibleToCheckmateIf(
                currentSide,
                promoteTo: .n(currentSide),
                in: pieces
            )
            
            canPromoteToBishop = !GameStateEvaluator.willLeadsToImpossibleToCheckmateIf(
                currentSide,
                promoteTo: .b(currentSide),
                in: pieces
            )
            
            showPromotionAlert.toggle()
        }
        
        // en passant
        if enPassant {
            let opponentPawnYIndex = currentSide == .white ? targetIndex.yIndex - 1 : targetIndex.yIndex + 1
            let opponentPawnPosition = BoardIndex(x: targetIndex.xIndex, y: opponentPawnYIndex)
            withAnimation(.easeOut(duration: 0.15)) {
                pieces[7 - opponentPawnPosition.yIndex][opponentPawnPosition.xIndex] = PieceViewModel(.none)
            }
        }
        
        // toggle castaling conditions
        toggleCastlingCondition(movedPiece: originPiece.item, originPosition: originIndex)
        
        // recover checking status
        if currentSide == sideInCheck {
            sideInCheck = nil
        }
        
        // toggle checking status
        toggleCheckStatus(for: currentSide.opponent)
        
        // toggle stalemate status
        toggleStalemateStatus(for: currentSide.opponent)
        
        // record move
        let newMove = Move(
            previous: moveRecorder.currentMove,
            from: originIndex,
            to: targetIndex,
            piece: originPiece.item,
            moveRound: currentRound,
            gameStatus: gameStatusAfterMove(
                sideAfterMove: currentSide.opponent,
                round: currentSide == PieceViewItem.PieceSide.white ? currentRound : currentRound + 1,
                turn: currentTurn + 1
            ),
            fen: nil,
            currentPiecesLayout: pieces
        )
        
        if moveRecorder.currentMove == nil {
            moveRecorder.currentMove = newMove
            moveRecorder.timeline = moveRecorder.currentMove
        } else {
            moveRecorder.currentMove?.next = newMove
            moveRecorder.currentMove = moveRecorder.currentMove?.next
        }
        
        // compute FEN after this move
        moveRecorder.currentMove?.fen = FEN.compute(
            with: self,
            side: currentSide.opponent,
            halfmoveClock: turnsAfterTakenOrPawnMoved,
            roundNumber: currentSide == PieceViewItem.PieceSide.white ? currentRound : currentRound + 1
        )
        
        // encrease round
        if currentSide == PieceViewItem.PieceSide.black {
            currentRound += 1
        }
        
        // encrease turn
        currentTurn += 1
        
        // toggle side
        currentSide = currentSide.opponent
        
        // threefold repetition
        threefoldRepetition = GameStateEvaluator.hasThreefoldRepetition(in: moveRecorder)
        
        // is insufficient material
        impossibleToCheckmate = GameStateEvaluator.isImpossibleToCheckmate(in: pieces)
        
        if gameBuilder.gameMode == .pve {
            submitCurrentFENToEngine()
        }
    }
    
    func promotion(to piece: PieceViewItem) {
        guard let promotionPosition = promotionPosition else { return }
        pieces[7 - promotionPosition.yIndex][promotionPosition.xIndex] = PieceViewModel(piece)
        
        toggleCheckStatus(for: currentSide)
        
        moveRecorder.currentMove?.promotion = piece
        moveRecorder.currentMove?.currentPiecesLayout[7 - promotionPosition.yIndex][promotionPosition.xIndex] = PieceViewModel(piece)
        
        self.promotionPosition = nil
        promotionSide = nil
        canPromoteToKnight = true
        canPromoteToBishop = true
    }
    
    func enPassantMoveTarget(for piece: PieceViewItem, at boardIndex: BoardIndex) -> BoardIndex? {
        guard let lastMove = moveRecorder.currentMove else { return nil }
        
        switch piece {
            case .p(let side):
                let enPassantLine = side == .white ? 4 : 3
                let enPassentTargetLine = side == .white ? 5 : 2
                let opponentPawnStartLine = side.opponent == .white ? 1 : 6
                guard boardIndex.yIndex == enPassantLine else { break }
                guard lastMove.piece == .p(side.opponent) else { break }
                guard lastMove.origin.yIndex == opponentPawnStartLine else { break }
                guard lastMove.target.yIndex == enPassantLine else { break }
                guard lastMove.target.xIndex == boardIndex.xIndex + 1 || lastMove.target.xIndex == boardIndex.xIndex - 1 else { break }
                return BoardIndex(x: lastMove.target.xIndex, y: enPassentTargetLine)
            default:
                break
        }
        
        return nil
    }
    
    private func submitCurrentFENToEngine() {
        guard let fen = moveRecorder.currentMove?.fen?.toString() else { return }
        if currentSide != gameBuilder.playerSide {
            engine?.submitFENToEngine(fen: fen)
        }
    }
    
    private func moveIsShortCastaling(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex
    ) -> Bool {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else { return false }
        let originPiece = pieces[7 - originIndex.yIndex][originIndex.xIndex]
        let xDistance = targetIndex.xIndex - originIndex.xIndex
        switch originPiece.item {
            case .k(_):
                if xDistance == 2 {
                    return true
                }
            default:
                break
        }
        
        return false
    }
    
    private func moveIsLongCastaling(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex
    ) -> Bool {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else { return false }
        let originPiece = pieces[7 - originIndex.yIndex][originIndex.xIndex]
        let xDistance = targetIndex.xIndex - originIndex.xIndex
        switch originPiece.item {
            case .k(_):
                if xDistance == -2 {
                    return true
                }
            default:
                break
        }
        
        return false
    }
    
    private func moveIsEnPassant(
        from originIndex: BoardIndex,
        to targetIndex: BoardIndex
    ) -> Bool {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else { return false }
        let originPiece = pieces[7 - originIndex.yIndex][originIndex.xIndex]
        let targetPiece = pieces[7 - targetIndex.yIndex][targetIndex.xIndex]
        let xDistance = targetIndex.xIndex - originIndex.xIndex
        switch originPiece.item {
            case .p(_):
                if xDistance != 0 && targetPiece.item == .none {
                    return true
                }
            default:
                break
        }
        
        return false
    }
    
    private func toggleCheckStatus(for side: PieceViewItem.PieceSide) {
        if GameStateEvaluator.isInCheck(
            for: side,
            in: pieces
        ) {
            sideInCheck = side
            moveRecorder.currentMove?.gameStatus.sideInCheck = side
            if GameStateEvaluator.isCheckmate(
                for: side,
                in: pieces
            ) {
                sideInCheckmate = side
            }
        }
    }
    
    private func toggleStalemateStatus(for side: PieceViewItem.PieceSide) {
        sideInStalemate = GameStateEvaluator.isStalemate(for: side, in: pieces) ? side : nil
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
                if pieceSide == .white && originPosition.xIndex == 7 {
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
    
    private func gameStatusAfterMove(
        sideAfterMove: PieceViewItem.PieceSide,
        round: Int,
        turn: Int
    ) -> GameStatus {
        GameStatus(
            currentSide: sideAfterMove,
            currentTurn: turn,
            currentRound: round,
            turnsAfterTakenOrPawnMoved: turnsAfterTakenOrPawnMoved,
            sideInCheck: sideInCheck,
            sideInCheckmate: sideInCheckmate,
            sideInStalemate: sideInStalemate,
            threefoldRepetition: threefoldRepetition,
            impossibleToCheckmate: impossibleToCheckmate,
            blackARookMoved: blackARookMoved,
            blackHRookMoved: blackHRookMoved,
            blackKingMoved: blackKingMoved,
            whiteARookMoved: whiteARookMoved,
            whiteHRookMoved: whiteHRookMoved,
            whiteKingMoved: whiteKingMoved
        )
    }
}

extension GameManager {
    func resetGame() {
        guard let initialMove = moveRecorder.initialPosition else { return }
        
        pieces = initialMove.currentPiecesLayout
        
        recoverGameStatus(to: initialMove.gameStatus)
        
        isReviewingHistory = false
        
        moveRecorder.timeline = nil
        moveRecorder.currentMove = nil
    }
    
    func stepBackward() {
        var previousMove = moveRecorder.currentMove?.previous
        if previousMove == nil {
            previousMove = moveRecorder.initialPosition
        }
        
        guard let previousMove = previousMove else { return }
        
        moveRecorder.currentMove = previousMove
        
        withAnimation(.easeOut(duration: 0.15)) {
            pieces = previousMove.currentPiecesLayout
        }
        
        recoverGameStatus(to: previousMove.gameStatus)
        
        isReviewingHistory = true
    }
    
    func stepForward() {
        var nextMove = moveRecorder.currentMove?.next
        
        if moveRecorder.currentMove == moveRecorder.initialPosition {
            nextMove = moveRecorder.timeline
        }
        
        guard let nextMove = nextMove else { return }
        
        moveRecorder.currentMove = nextMove
        
        withAnimation(.easeOut(duration: 0.15)) {
            pieces = nextMove.currentPiecesLayout
        }
        
        recoverGameStatus(to: nextMove.gameStatus)
        
        isReviewingHistory = nextMove.next != nil
    }
    
    private func recoverGameStatus(to gameStatus: GameStatus) {
        currentSide = gameStatus.currentSide
        currentTurn = gameStatus.currentTurn
        currentRound = gameStatus.currentRound
        turnsAfterTakenOrPawnMoved = gameStatus.turnsAfterTakenOrPawnMoved
        sideInCheck = gameStatus.sideInCheck
        sideInCheckmate = gameStatus.sideInCheckmate
        sideInStalemate = gameStatus.sideInStalemate
        threefoldRepetition = gameStatus.threefoldRepetition
        impossibleToCheckmate = gameStatus.impossibleToCheckmate
        blackARookMoved = gameStatus.blackARookMoved
        blackHRookMoved = gameStatus.blackHRookMoved
        blackKingMoved = gameStatus.blackKingMoved
        whiteARookMoved = gameStatus.whiteARookMoved
        whiteHRookMoved = gameStatus.whiteHRookMoved
        whiteKingMoved = gameStatus.whiteKingMoved
    }
}
