//
//  BoardCell.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct BoardCell: View {
    let cellIndex: BoardIndex
    var inReversedBoard: Bool = false
    
    var color: Color {
        (cellIndex.yIndex + cellIndex.xIndex) % 2 == 0 ? .blue : Color(hex: "#C7DEFF")
    }
    
    var onBoardCellSelected: ((BoardIndex) -> Void)?
    
    var body: some View {
        Button {
            print("点击了棋盘，位置：\(cellIndex.toPositionStr())")
            onBoardCellSelected?(cellIndex)
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(color)
                
                VStack {
                    if (cellIndex.xIndex == 0) {
                        HStack {
                            Text(cellIndex.getYPosition())
                                .foregroundColor(.white)
                                .padding([.leading, .trailing], 4)
                                .padding([.top], 2)
                                .font(.footnote)
                                .rotationEffect(inReversedBoard ? .degrees(180) : .degrees(0))
                            Spacer()
                        }
                    }
                    
                    Spacer()
                    
                    if (cellIndex.yIndex == 0) {
                        HStack {
                            Spacer()
                            Text(cellIndex.getXPosition())
                                .foregroundColor(.white)
                                .padding([.leading, .trailing], 4)
                                .padding([.bottom], 2)
                                .font(.footnote)
                                .rotationEffect(inReversedBoard ? .degrees(180) : .degrees(0))
                        }
                    }
                }
            }
        }
    }
}

struct BoardCell_Previews: PreviewProvider {
    static var previews: some View {
        BoardCell(cellIndex: BoardIndex.getOriginIndex())
            .frame(width: 50, height: 50)
    }
}
