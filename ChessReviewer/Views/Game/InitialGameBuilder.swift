//
//  InitialGameBuilder.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/4/12.
//

import Foundation

enum GameMode {
    case pvp
    case pve
    case analysis
}

enum HistoryControlMode {
    /// 正常对局，不能悔棋，只能回顾历史但不能修改
    case playStrict
    /// 正常对局，允许悔棋并修改己方走法，原有走法会被覆盖
    case playFlexible
    /// 分支分析模式，允许任意新建走法分支
    case analysis
}

class InitialGameBuilder {
    var gameMode: GameMode
    var historyControlMode: HistoryControlMode
    var pieces: [[PieceViewModel]]
    var currentMoveSide: PieceViewItem.PieceSide
    var playerSide: PieceViewItem.PieceSide
    var enPassantTarget: BoardIndex?
    var canWhiteShortCastling: Bool
    var canWhiteLongCastling: Bool
    var canBlackShortCastling: Bool
    var canBlackLongCastling: Bool
    
    init(
        gameMode: GameMode,
        historyControlMode: HistoryControlMode,
        pieces: [[PieceViewModel]]? = nil,
        currentMoveSide: PieceViewItem.PieceSide? = nil,
        playerSide: PieceViewItem.PieceSide? = nil,
        enPassantTarget: BoardIndex? = nil,
        canWhiteShortCastling: Bool? = nil,
        canWhiteLongCastling: Bool? = nil,
        canBlackShortCastling: Bool? = nil,
        canBlackLongCastling: Bool? = nil
    ) {
        self.gameMode = gameMode
        self.historyControlMode = historyControlMode
        self.pieces = pieces ?? InitialGameBuilder.initialGrid()
        self.currentMoveSide = currentMoveSide ?? .white
        self.playerSide = playerSide ?? .white
        self.enPassantTarget = enPassantTarget
        self.canWhiteShortCastling = canWhiteShortCastling ?? true
        self.canWhiteLongCastling = canWhiteLongCastling ?? true
        self.canBlackShortCastling = canBlackShortCastling ?? true
        self.canBlackLongCastling = canBlackLongCastling ?? true
    }
    
    
    static func initialGrid() -> [[PieceViewModel]] {
        [
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
}
