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
    
    static func fromString(indexString: String) -> BoardIndex? {
        guard indexString.count == 2 else { return nil }
        
        let xIndexString = indexString.prefix(1)
        let yIndexString = indexString.suffix(1)
        
        guard let xIndex = (xIndexStrs.firstIndex { $0 == xIndexString }) else { return nil }
        guard let yIndex = (yIndexStrs.firstIndex { $0 == yIndexString }) else { return nil }
        
        return BoardIndex(x: xIndex, y: yIndex)
    }
}
