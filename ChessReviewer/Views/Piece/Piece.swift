//
//  Material.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Piece: View {
    let pieceViewModel: PieceViewItem
    var position: BoardIndex
    var onPieceSelected: ((PieceViewItem, BoardIndex) -> Void)?
    
    init(
        model pieceViewModel: PieceViewItem,
        position: BoardIndex,
        onPieceSelected: @escaping (PieceViewItem, BoardIndex) -> Void = { _, _ in }
    ) {
        self.pieceViewModel = pieceViewModel
        self.position = position
        self.onPieceSelected = onPieceSelected
    }
    
    var body: some View {
        Button {
            onPieceSelected?(pieceViewModel, position)
        } label: {
            ZStack {
                Text(pieceViewModel.pieceNotation)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Material_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BoardCell(cellIndex: BoardIndex.getOriginIndex())
            Piece(model: .r(.white), position: BoardIndex.getOriginIndex())
        }
        .frame(width: 50, height: 50)
    }
}
