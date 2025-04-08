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
    var turn: Int
    var round: Int
    var branches: [Move]?
    var origin: BoardIndex
    var target: BoardIndex
    var gameStatus: GameStatus
    var currentPiecesLayout: [[PieceViewModel]]
    
    init(
        next: Move? = nil,
        previous: Move? = nil,
        turn: Int,
        round: Int,
        from origin: BoardIndex,
        to target: BoardIndex,
        gameStatus: GameStatus,
        currentPiecesLayout: [[PieceViewModel]]
    ) {
        self.next = next
        self.previous = previous
        self.turn = turn
        self.round = round
        self.origin = origin
        self.target = target
        self.gameStatus = gameStatus
        self.currentPiecesLayout = currentPiecesLayout
    }
}

class MoveRecorder: ObservableObject {
    @Published var timeline: Move?
    
    var mainBranchRoundsArray: [String] {
        guard let start = timeline else { return [] }
        
        var cur: Move? = start
        var currentRound: [String] = []
        var rounds: [String] = []
        
        while let move = cur {
            if move.round == move.previous?.round ?? 1 {
                currentRound.append(move.origin.toPositionStr() + move.target.toPositionStr())
            } else {
                rounds.append(currentRound.joined(separator: " "))
                currentRound = [move.origin.toPositionStr() + move.target.toPositionStr()]
            }
            cur = cur?.next
        }
        
        if currentRound.count != 0 {
            rounds.append(currentRound.joined(separator: " "))
        }
        
        return rounds
    }
    
    var mainBranchMovesArray: [String] {
        var moves: [String] = []
        var cur: Move? = timeline
        
        while let move = cur {
            moves.append(move.origin.toPositionStr() + move.target.toPositionStr())
            cur = move.next
        }
        
        return moves
    }
    
    var mainBranchMovesString: String {
        return mainBranchMovesArray.joined(separator: " ")
    }
}
