//
//  PiecesLayer.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct PiecesLayer: View {
    @Binding var pieces: [[PieceViewItem]]
    var onPieceSelected: (PieceViewItem, BoardIndex) -> Void = { _, _ in }
    
    var isPiecesLegal: Bool {
        pieces.count == 8 && pieces.allSatisfy({ $0.count <= 8 })
    }
    
    var body: some View {
        if !isPiecesLegal {
            VStack {
                Text("Pieces Error")
            }
        } else {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ForEach(0..<8) { yIndex in
                        HStack(spacing: 0) {
                            ForEach(0..<8) { xIndex in
                                Group {
                                    switch pieces[yIndex][xIndex] {
                                        case .none:
                                            Color.clear
                                                .contentShape(Rectangle())
                                                .allowsHitTesting(false)
                                        default:
                                            Piece(
                                                model: pieces[yIndex][xIndex],
                                                position: BoardIndex(x: xIndex, y: 8 - yIndex - 1),
                                                onPieceSelected: onPieceSelected
                                            )
                                    }
                                }
                                .frame(
                                    width: geometry.size.width / 8.0,
                                    height: geometry.size.height / 8.0
                                )
                            }
                        }
                    }
                }
            }
            .padding(5)
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

struct PiecesLayer_Previews: PreviewProvider {
    static var previews: some View {
        let pieces = [
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
        ZStack {
            Board(piecesManager: PiecesManager())
            PiecesLayer(pieces: .constant(pieces))
        }
    }
}
