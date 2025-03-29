//
//  BoardIndex.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import Foundation

fileprivate let xIndexStrs = ["a", "b", "c", "d", "e", "f", "g", "h"]
fileprivate let yIndexStrs = ["1", "2", "3", "4", "5", "6", "7", "8"]

struct BoardIndex: Equatable {
    let xIndex: Int
    let yIndex: Int
    
    static func getOriginIndex() -> Self {
        return BoardIndex(x: 0, y: 0)
    }
    
    init(x xIndex: Int, y yIndex: Int) {
        self.xIndex = xIndex
        self.yIndex = yIndex
    }
    
    func toPositionStr() -> String {
        xIndexStrs[xIndex] + yIndexStrs[yIndex]
    }
    
    func getYPosition() -> String {
        yIndexStrs[yIndex]
    }
    
    func getXPosition() -> String {
        xIndexStrs[xIndex]
    }
}
