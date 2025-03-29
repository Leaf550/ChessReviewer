//
//  PiecesManager.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import Foundation

class PiecesManager: ObservableObject {
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
        return selectedPiece.movementRule.possibleMoves(at: selectedPieceIndex, in: self)
    }
    
    @Published var pieces: [[PieceViewItem]] = [
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [.none, .none, .none, .none, .b(.white), .none, .none, .none],
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
        [PieceViewItem](repeating: .none, count: 8),
    ]
    
    func getPiece(at index: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(index.xIndex),
              (0...7).contains(index.yIndex) else {
            return .none
        }
        return pieces[7 - index.yIndex][index.xIndex]
    }
}
