//
//  MoveIndicator.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import SwiftUI

struct MoveIndicator: View {
    @ObservedObject var manager: PiecesManager
    let targetIndex: BoardIndex
    
    var body: some View {
        Button {
            guard let selectedIndex = manager.selectedPieceIndex else { return }
            manager.movePiece(from: selectedIndex, to: targetIndex)
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                Circle()
                    .frame(width: 14)
                    .foregroundColor(.white)
                    .opacity(0.6)
            }
        }
    }
}

struct MoveIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MoveIndicator(manager: PiecesManager(), targetIndex: BoardIndex.getOriginIndex())
        }
        .frame(width: 200, height: 200)
        .background(.blue)
    }
}
