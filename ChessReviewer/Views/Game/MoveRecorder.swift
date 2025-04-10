//
//  MoveRecorder.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/30.
//

import Foundation

struct GameStatus {
    var currentSide: PieceViewItem.PieceSide
    var currentTurn: Int
    var currentRound: Int
    var turnsAfterTakenOrPawnMoved: Int
    var sideInCheck: PieceViewItem.PieceSide?
    var sideInCheckmate: PieceViewItem.PieceSide?
    var blackARookMoved: Bool
    var blackHRookMoved: Bool
    var blackKingMoved: Bool
    var whiteARookMoved: Bool
    var whiteHRookMoved: Bool
    var whiteKingMoved: Bool
    
    static func empty() -> GameStatus {
        return GameStatus(
            currentSide: .white,
            currentTurn: 1,
            currentRound: 1,
            turnsAfterTakenOrPawnMoved: 0,
            sideInCheck: nil,
            sideInCheckmate: nil,
            blackARookMoved: false,
            blackHRookMoved: false,
            blackKingMoved: false,
            whiteARookMoved: false,
            whiteHRookMoved: false,
            whiteKingMoved: false
        )
    }
}

class Move {
    var next: Move?
    var previous: Move?
    var branches: [Move]?
    var origin: BoardIndex
    var target: BoardIndex
    var piece: PieceViewItem
    var promotion: PieceViewItem?
    var gameStatus: GameStatus
    var fen: String
    var currentPiecesLayout: [[PieceViewModel]]
    
    init(
        next: Move? = nil,
        previous: Move? = nil,
        from origin: BoardIndex,
        to target: BoardIndex,
        piece: PieceViewItem,
        gameStatus: GameStatus,
        fen: String,
        currentPiecesLayout: [[PieceViewModel]]
    ) {
        self.next = next
        self.previous = previous
        self.origin = origin
        self.target = target
        self.piece = piece
        self.gameStatus = gameStatus
        self.fen = fen
        self.currentPiecesLayout = currentPiecesLayout
    }
}

class MoveRecorder: ObservableObject {
    @Published var timeline: Move?
    var currentMove: Move?
    
    var mainBranchRoundsArray: [String] {
        var res: [String] = []
        var ptr = currentMove
        
        var lastRound = ptr?.gameStatus.currentRound
        var movesInRound: [String] = []
        while ptr != nil {
            let currentRound = ptr?.gameStatus.currentRound
            
            if currentRound != lastRound {
                res.append(movesInRound.joined(separator: " "))
                movesInRound = []
            }
            
            let currentTurnMove = (ptr?.origin.toPositionStr() ?? "") + (ptr?.target.toPositionStr() ?? "") + (ptr?.promotion?.pieceNotation ?? "").lowercased()
            
            movesInRound.insert(currentTurnMove, at: 0)
            
            ptr = ptr?.previous
            lastRound = currentRound
        }
        
        if movesInRound.count != 0 {
            res.append(movesInRound.joined(separator: " "))
        }
        
        return res.reversed()
    }
    
    var mainBranchMovesString: String {
        mainBranchRoundsArray.joined(separator: " ")
    }
}
