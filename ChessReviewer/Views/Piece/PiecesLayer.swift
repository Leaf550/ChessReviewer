//
//  PiecesLayer.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct PiecesLayer: View {
    @ObservedObject var gameManager: GameManager
    var onReversedBoard: Bool = false
    
    private var isPiecesLegal: Bool {
        gameManager.pieces.count == 8 && gameManager.pieces.allSatisfy({ $0.count <= 8 })
    }
    
    private func movePiece(from originIndex: BoardIndex, to targetIndex: BoardIndex) {
        guard let targetMovement = (gameManager.selectedPiecePossibleMovements.first {
            $0.to == targetIndex
        }) else { return }
        
        print("111123123")
        
        gameManager.movePiece(
            from: originIndex,
            to: targetMovement.to
        )
    }
    
    var body: some View {
        if isPiecesLegal {
            piecesGrid()
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
                .rotationEffect(onReversedBoard ? .degrees(180) : .degrees(0))
                .alert("升变！", isPresented: $gameManager.showPromotionAlert) {
                    Button("车", role: .none) {
                        guard let promotionSide = gameManager.promotionSide else { return }
                        gameManager.promotion(to: .r(promotionSide))
                    }
                    if gameManager.canPromoteToKnight {
                        Button("马", role: .none) {
                            guard let promotionSide = gameManager.promotionSide else { return }
                            gameManager.promotion(to: .n(promotionSide))
                        }
                    }
                    if gameManager.canPromoteToBishop {
                        Button("象", role: .none) {
                            guard let promotionSide = gameManager.promotionSide else { return }
                            gameManager.promotion(to: .b(promotionSide))
                        }
                    }
                    Button("后", role: .none) {
                        guard let promotionSide = gameManager.promotionSide else { return }
                        gameManager.promotion(to: .q(promotionSide))
                    }
                }
        } else {
            errorView
        }
    }
        
    private func piecesGrid() -> some View {
        GeometryReader { geometry in
            let size = geometry.size.width / 8.0
            let columns = [GridItem(.adaptive(minimum: size), spacing: 0)]
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(
                    gameManager.pieces.flatMap { $0 },
                    id: \.id
                ) { model in
                    let index = gameManager.pieces.flatMap { $0 }.firstIndex { $0.id == model.id }
                    if let index = index {
                        let x = index % 8
                        let y = 7 - index / 8
                        let position = BoardIndex(x: x, y: y)
                        let pieceItem = gameManager.getPiece(at: position)
                        let isPossibleMove = gameManager.selectedPiecePossibleMovements.contains { $0.to == position }
                        EquatableView(
                            content: PieceCell(
                                pieceItem: pieceItem,
                                isPossibleMove: isPossibleMove,
                                position: position
                            ) {
                                guard gameManager.currentSide == pieceItem.side else { return }
                                
                                if gameManager.gameBuilder.gameMode == .pve && gameManager.currentSide != gameManager.gameBuilder.playerSide {
                                    return
                                }
                                
                                if gameManager.isReviewingHistory
                                    && gameManager.gameBuilder.historyControlMode == .playStrict {
                                    return
                                }
                                gameManager.selectedPieceIndex = position
                            } onMoveIndicatorTapped: {
                                guard let selectedPieceIndex = gameManager.selectedPieceIndex else { return }
                                movePiece(from: selectedPieceIndex, to: position)
                            }
                        )
                        .frame(width: size, height: size)
                        .rotationEffect(onReversedBoard ? .degrees(180) : .degrees(0))
                    }
                }
            }
        }
    }
    
    private var errorView: some View {
        VStack {
            Text("棋子布局异常")
                .font(.headline)
            Text("请检查棋子数组维度")
                .font(.subheadline)
        }
        .foregroundColor(.red)
    }
}

struct PiecesLayer_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Board()
            let gameManager = GameManager(
                gameBuilder: InitialGameBuilder(
                    gameMode: .pvp, historyControlMode: .playStrict
                )
            )
            if let gameManager = gameManager {
                PiecesLayer(gameManager: gameManager)
            } else {
                Text("gameBuilder 配置有误")
            }
        }.padding()
    }
}
