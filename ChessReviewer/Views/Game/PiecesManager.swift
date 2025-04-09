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
    var turnsAfterTakenOrPawnMoved = 0
    
    @Published var sideInCheck: PieceViewItem.PieceSide?
    @Published var sideInCheckmate: PieceViewItem.PieceSide?
    @Published var sideInStalemate: PieceViewItem.PieceSide?
    
    var blackARookMoved: Bool = false
    var blackHRookMoved: Bool = false
    var blackKingMoved: Bool = false
    
    var whiteARookMoved: Bool = false
    var whiteHRookMoved: Bool = false
    var whiteKingMoved: Bool = false
    
    var canWhiteShortCastling: Bool {
        sideInCheck != .white
        && !whiteHRookMoved
        && !whiteKingMoved
        && getPiece(at: BoardIndex(x: 7, y: 0)) == .r(.white)
    }
    
    var canWhiteLongCastling: Bool {
        sideInCheck != .white
        && !whiteARookMoved
        && !whiteKingMoved
        && getPiece(at: BoardIndex(x: 0, y: 0)) == .r(.white)
    }
    
    var canBlackShortCastling: Bool {
        sideInCheck != .black
        && !blackHRookMoved
        && !blackKingMoved
        && getPiece(at: BoardIndex(x: 7, y: 7)) == .r(.black)
    }
    
    var canBlackLongCastling: Bool {
        sideInCheck != .black
        && !blackARookMoved
        && !blackKingMoved
        && getPiece(at: BoardIndex(x: 0, y: 7)) == .r(.black)
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
        
        if let enPassantMove = enPassantMoveTarget(for: selectedPiece, at: selectedPieceIndex) {
            res.append(PossibbleMovement(to: enPassantMove, enPassant: true))
        }
        
        return res
    }
    
    var currentGameStatus: GameStatus {
        GameStatus(
            currentSide: currentSide,
            currentTurn: currentTurn,
            currentRound: currentRound,
            turnsAfterTakenOrPawnMoved: turnsAfterTakenOrPawnMoved,
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
    
    var currentFEN: String {
        var res = ""
        var enPassantTarget: String? = nil
        var foundEnPassantTarget = false
        for (rowIndex, row) in pieces.enumerated() {
            var blankCount = 0
            for (columnIndex, piece) in row.enumerated() {
                switch piece.item {
                    case .none:
                        blankCount += 1
                    default:
                        if blankCount != 0 {
                            res += "\(blankCount)"
                        }
                        blankCount = 0
                        res += piece.item.pieceNotation
                        
                        if !foundEnPassantTarget {
                            switch piece.item {
                                case .p(_):
                                    enPassantTarget = enPassantMoveTarget(for: piece.item, at: BoardIndex(x: columnIndex, y: 7 - rowIndex))?.toPositionStr()
                                    foundEnPassantTarget = enPassantTarget != nil
                                default:
                                    break
                            }
                        }
                }
            }
            if blankCount != 0 {
                res += "\(blankCount)"
            }
            if rowIndex != 7 {
                res += "/"
            }
        }
        
        res += " "
        res += currentTurn == 1 ? "w" : (currentSide == .white.opponent ? "w" : "b")
        
        res += " "
        if !canWhiteShortCastling
            && !canWhiteLongCastling
            && !canBlackShortCastling
            && !canBlackLongCastling {
            res += "-"
        } else {
            if canWhiteShortCastling {
                res += "K"
            }
            if canWhiteLongCastling {
                res += "Q"
            }
            if canBlackShortCastling {
                res += "k"
            }
            if canBlackLongCastling {
                res += "q"
            }
        }
        
        res += " "
        res += "\(enPassantTarget ?? "-")"
            
        
        res += " "
        res += "\(turnsAfterTakenOrPawnMoved)"
        
        res += " \(currentSide.opponent == .white ? currentRound + 1 : currentRound)"
        
        return res
    }
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
              (0...7).contains(targetIndex.yIndex) else { return }
        
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
            gameStatus: currentGameStatus,
            fen: "",
            currentPiecesLayout: pieces
        )
        
        if moveRecorder.currentMove == nil {
            moveRecorder.currentMove = newMove
            moveRecorder.timeline = moveRecorder.currentMove
        } else {
            moveRecorder.currentMove?.next = newMove
            moveRecorder.currentMove = moveRecorder.currentMove?.next
        }
        
        // encrease turn
        currentTurn += 1
        
        // compute FEN after this move
        moveRecorder.currentMove?.fen = currentFEN
        
        // encrease round
        if currentSide == PieceViewItem.PieceSide.black {
            currentRound += 1
        }
        
        // toggle side
        currentSide = currentSide.opponent
    }
    
    func promotion(to piece: PieceViewItem) {
        guard let promotionPosition = promotionPosition else { return }
        pieces[7 - promotionPosition.yIndex][promotionPosition.xIndex] = PieceViewModel(piece)
        
        toggleCheckStatus(for: currentSide)
        
        moveRecorder.currentMove?.promotion = piece
        
        self.promotionPosition = nil
        promotionSide = nil
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
    
    private func enPassantMoveTarget(for piece: PieceViewItem, at boardIndex: BoardIndex) -> BoardIndex? {
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
