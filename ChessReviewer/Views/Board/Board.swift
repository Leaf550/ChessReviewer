//
//  Board.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct Board: View {
    var onBoardCellSelected: ((BoardIndex) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach((0..<8).reversed(), id: \.self) { yIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<8) { xIndex in
                            let currentIndex = BoardIndex(x: xIndex, y: yIndex)
                            BoardCell(
                                cellIndex: currentIndex,
                                onBoardCellSelected: onBoardCellSelected
                            ).frame(
                                width: geometry.size.width / 8.0,
                                height: geometry.size.height / 8.0
                            )
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(5)
        .border(.blue, width: 5)
    }
}

struct Board_Previews: PreviewProvider {
    static var previews: some View {
        Board()
    }
}
