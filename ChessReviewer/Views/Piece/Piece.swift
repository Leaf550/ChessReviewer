//
//  Material.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Piece: View {
    let pieceViewItem: PieceViewItem
    var onPieceButtonTapped: (() -> Void)
    
    init(
        pieceViewItem: PieceViewItem,
        onPieceButtonTapped: @escaping (() -> Void)
    ) {
        self.pieceViewItem = pieceViewItem
        self.onPieceButtonTapped = onPieceButtonTapped
    }
    
    var body: some View {
        Button {
            onPieceButtonTapped()
        } label: {
            ZStack {
                Image(pieceViewItem.pieceImageName)
                    .resizable()
                    .padding(3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Material_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BoardCell(cellIndex: BoardIndex.getOriginIndex())
            Piece(pieceViewItem: .r(.white)) {}
        }
        .frame(width: 50, height: 50)
    }
}
