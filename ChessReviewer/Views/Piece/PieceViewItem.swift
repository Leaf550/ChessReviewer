//
//  MaterialModel.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import Foundation

enum PieceViewItem: Equatable {
    enum PieceSide: String {
        case white = "white"
        case black = "black"
    }
    
    case p(PieceSide)
    case r(PieceSide)
    case n(PieceSide)
    case b(PieceSide)
    case q(PieceSide)
    case k(PieceSide)
    case none
}

extension PieceViewItem {
    var side: PieceSide? {
        switch self {
            case .p(let side): return side
            case .r(let side): return side
            case .n(let side): return side
            case .b(let side): return side
            case .q(let side): return side
            case .k(let side): return side
            case .none: return nil
        }
    }
}

extension PieceViewItem {
    var pieceNotation: String {
        switch self {
            case .p(let side): return side == .white ? "P" : "p"
            case .r(let side): return side == .white ? "R" : "r"
            case .n(let side): return side == .white ? "N" : "n"
            case .b(let side): return side == .white ? "B" : "b"
            case .q(let side): return side == .white ? "Q" : "q"
            case .k(let side): return side == .white ? "K" : "k"
            case .none: return ""
        }
    }
    
    var pieceCommonName: String {
        switch self {
            case .p(let side): return  "\(side.rawValue) pawn"
            case .r(let side): return  "\(side.rawValue) rook"
            case .n(let side): return  "\(side.rawValue) knight"
            case .b(let side): return  "\(side.rawValue) bishop"
            case .q(let side): return  "\(side.rawValue) queen"
            case .k(let side): return  "\(side.rawValue) king"
            case .none: return ""
        }
    }
}
