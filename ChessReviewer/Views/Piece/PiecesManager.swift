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
    
    func getPiece(at index: BoardIndex) -> PieceViewItem {
        guard (0...7).contains(index.xIndex),
              (0...7).contains(index.yIndex) else {
            return .none
        }
        return pieces[7 - index.yIndex][index.xIndex]
    }
    
    func movePiece(from originIndex: BoardIndex, to targetIndex: BoardIndex) {
        guard (0...7).contains(originIndex.xIndex),
              (0...7).contains(originIndex.yIndex),
              (0...7).contains(targetIndex.xIndex),
              (0...7).contains(targetIndex.yIndex) else {
            return
        }
        let originPiece = getPiece(at: originIndex)
        pieces[7 - originIndex.yIndex][originIndex.xIndex] = .none
        pieces[7 - targetIndex.yIndex][targetIndex.xIndex] = originPiece
    }
}
