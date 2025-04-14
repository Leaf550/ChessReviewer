//
//  Engine.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/4/14.
//

import Foundation
import ChessKitEngine

class UCIEngine {
    let engine = Engine(type: .stockfish)
    
    var foundBestMove: (_ from: BoardIndex, _ to: BoardIndex) -> Void
    
    init(foundBestMove: @escaping ((_ from: BoardIndex, _ to: BoardIndex) -> Void)) {
        self.foundBestMove = foundBestMove
        
        engine.start(coreCount: 2) {
            
        }
        
        engine.receiveResponse = { response in
            switch response {
                case .bestmove(let move, let ponder):
                    print(move, ponder ?? "")
                    if let bordIndexMove = self.convertUCIMoveToBoardIndex(uciMove: move) {
                        foundBestMove(bordIndexMove.0, bordIndexMove.1)
                    }
                default:
                    print(response)
                    break
            }
        }
    }
    
    func submitFENToEngine(fen: String) {
        engine.send(command: .stop)
        engine.send(command: .position(.fen(fen)))
        engine.send(command: .go(depth: 10))
    }
    
    private func convertUCIMoveToBoardIndex(uciMove: String) -> (BoardIndex, BoardIndex)? {
        guard uciMove.count >= 4 else { return nil }
        
        let uciMove = uciMove.prefix(4)
        
        let originPosition = uciMove.prefix(2)
        let targetPosition = uciMove.suffix(2)
        
        guard let originIndex = BoardIndex.fromString(indexString: String(originPosition)) else { return nil }
        guard let targetIndex = BoardIndex.fromString(indexString: String(targetPosition)) else { return nil }
        
        return (originIndex, targetIndex)
    }
}
