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
    var sideInStalemate: PieceViewItem.PieceSide?
    var threefoldRepetition: Bool
    var impossibleToCheckmate: Bool
    var blackARookMoved: Bool
    var blackHRookMoved: Bool
    var blackKingMoved: Bool
    var whiteARookMoved: Bool
    var whiteHRookMoved: Bool
    var whiteKingMoved: Bool
}

struct FEN {
    enum CastalingAvailability: String {
        case K = "K"
        case Q = "Q"
        case k = "k"
        case q = "q"
    }
    
    var piecePlacement: String
    var activeSide: PieceViewItem.PieceSide
    var castlingAvailability: [CastalingAvailability]
    var enPassantTarget: BoardIndex?
    var halfmoveClock: Int
    var roundNumber: Int
    
    static func compute(
        with gameManager: GameManager,
        side: PieceViewItem.PieceSide,
        halfmoveClock: Int,
        roundNumber: Int
    ) -> Self {
        // 棋子布局
        let piecesPlacement = piecesPlacementString(from: gameManager.pieces)
        var enPassantTarget: BoardIndex? = nil
        var foundEnPassantTarget = false
        for (rowIndex, row) in gameManager.pieces.enumerated() {
            for (columnIndex, piece) in row.enumerated() {
                switch piece.item {
                    case .none:
                        break
                    default:
                        if !foundEnPassantTarget {
                            switch piece.item {
                                case .p(_):
                                    enPassantTarget = gameManager.enPassantMoveTarget(for: piece.item, at: BoardIndex(x: columnIndex, y: 7 - rowIndex))
                                    foundEnPassantTarget = enPassantTarget != nil
                                default:
                                    break
                            }
                        }
                }
            }
        }
        
        // 走棋方
        let activeSide = side
        
        // 易位权
        var castalingAvailability: [CastalingAvailability] = []
        if gameManager.canWhiteShortCastling {
            castalingAvailability.append(.K)
        }
        if gameManager.canWhiteLongCastling {
            castalingAvailability.append(.Q)
        }
        if gameManager.canBlackShortCastling {
            castalingAvailability.append(.k)
        }
        if gameManager.canBlackLongCastling {
            castalingAvailability.append(.q)
        }
        
        return FEN(
            piecePlacement: piecesPlacement,
            activeSide: activeSide,
            castlingAvailability: castalingAvailability,
            enPassantTarget: enPassantTarget,
            halfmoveClock: halfmoveClock,
            roundNumber: roundNumber
        )
    }
    
    static func initialGameFEN() -> Self {
        return FEN(
            piecePlacement: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
            activeSide: .white,
            castlingAvailability: [.K, .Q, .k, .q],
            halfmoveClock: 0,
            roundNumber: 1
        )
    }
    
    static func fromInitialGameBuilder(_ builder: InitialGameBuilder) -> Self {
        var castlingAvailability: [CastalingAvailability] = []
        if builder.canWhiteShortCastling {
            castlingAvailability.append(.K)
        }
        if builder.canWhiteLongCastling {
            castlingAvailability.append(.Q)
        }
        if builder.canBlackShortCastling {
            castlingAvailability.append(.k)
        }
        if builder.canBlackLongCastling {
            castlingAvailability.append(.q)
        }
        
        return FEN(
            piecePlacement: piecesPlacementString(from: builder.pieces),
            activeSide: builder.currentMoveSide,
            castlingAvailability: castlingAvailability,
            enPassantTarget: builder.enPassantTarget,
            halfmoveClock: 0,
            roundNumber: 1
        )
    }
    
    func toString() -> String {
        return ""
        + "\(piecePlacement) "
        + "\(activeSide.abbreviation) "
        + "\(castlingAvailability.map { $0.rawValue }.joined()) "
        + "\(enPassantTarget?.toPositionStr() ?? "-") "
        + "\(halfmoveClock) "
        + "\(roundNumber) "
    }
    
    func fenWithoutHalfmoveClockAndRoundString() -> String {
        return ""
        + "\(piecePlacement) "
        + "\(activeSide.abbreviation) "
        + "\(castlingAvailability.map { $0.rawValue }.joined()) "
        + "\(enPassantTarget?.toPositionStr() ?? "-")"
    }
    
    private static func piecesPlacementString(from pieces: [[PieceViewModel]]) -> String {
        var piecesPlacement = ""
        
        for (rowIndex, row) in pieces.enumerated() {
            var blankCount = 0
            for piece in row {
                switch piece.item {
                    case .none:
                        blankCount += 1
                    default:
                        if blankCount != 0 {
                            piecesPlacement += "\(blankCount)"
                        }
                        blankCount = 0
                        piecesPlacement += piece.item.pieceNotation
                }
            }
            if blankCount != 0 {
                piecesPlacement += "\(blankCount)"
            }
            if rowIndex != 7 {
                piecesPlacement += "/"
            }
        }
        
        return piecesPlacement
    }
}

class Move: Equatable {
    var id = UUID()
    var next: Move?
    weak var previous: Move?
    var branches: [Move]?
    var origin: BoardIndex
    var target: BoardIndex
    var piece: PieceViewItem
    var moveRound: Int
    var promotion: PieceViewItem?
    var gameStatus: GameStatus
    var fen: FEN?
    var currentPiecesLayout: [[PieceViewModel]]
    
    init(
        next: Move? = nil,
        previous: Move? = nil,
        from origin: BoardIndex,
        to target: BoardIndex,
        piece: PieceViewItem,
        moveRound: Int,
        gameStatus: GameStatus,
        fen: FEN?,
        currentPiecesLayout: [[PieceViewModel]]
    ) {
        self.next = next
        self.previous = previous
        self.origin = origin
        self.target = target
        self.piece = piece
        self.moveRound = moveRound
        self.gameStatus = gameStatus
        self.fen = fen
        self.currentPiecesLayout = currentPiecesLayout
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        lhs.id == rhs.id
    }
}

class MoveRecorder: ObservableObject {
    @Published var timeline: Move?
    var currentMove: Move?
    var initialPosition: Move?
    
    var currentBranchLatestMove: Move? {
        var ptr = currentMove == initialPosition ? timeline : currentMove
        while ptr?.next != nil {
            ptr = ptr?.next
        }
        return ptr
    }
    
    var mainBranchRoundsArray: [String] {
        var res: [String] = []
        var ptr = currentBranchLatestMove
        
        var lastRound = ptr?.moveRound
        var movesInRound: [String] = []
        while ptr != nil {
            let currentRound = ptr?.moveRound
            
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
