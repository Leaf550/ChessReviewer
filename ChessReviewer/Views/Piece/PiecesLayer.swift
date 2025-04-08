//
//  PiecesLayer.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct PiecesLayer: View {
    @ObservedObject var piecesManager: PiecesManager
    var onReversedBoard: Bool = false
    
    private var isPiecesLegal: Bool {
        piecesManager.pieces.count == 8 && piecesManager.pieces.allSatisfy({ $0.count <= 8 })
    }
    
    private func movePiece(from originIndex: BoardIndex, to targetIndex: BoardIndex) {
        guard let targetMovement = (piecesManager.selectedPiecePossibleMovements.first {
            $0.to == targetIndex
        }) else { return }
        
        piecesManager.movePiece(
            from: originIndex,
            to: targetMovement.to,
            isShortCastaling: targetMovement.shortCastaling,
            isLongCastling: targetMovement.longCastaling,
            enPassant: targetMovement.enPassant
        )
    }
    
    var body: some View {
        if isPiecesLegal {
            piecesGrid()
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
                .rotationEffect(onReversedBoard ? .degrees(180) : .degrees(0))
                .alert("升变！", isPresented: $piecesManager.showPromotionAlert) {
                    Button("车", role: .none) {
                        guard let promotionSide = piecesManager.promotionSide else { return }
                        piecesManager.promotion(to: .r(promotionSide))
                    }
                    Button("马", role: .none) {
                        guard let promotionSide = piecesManager.promotionSide else { return }
                        piecesManager.promotion(to: .n(promotionSide))
                    }
                    Button("象", role: .none) {
                        guard let promotionSide = piecesManager.promotionSide else { return }
                        piecesManager.promotion(to: .b(promotionSide))
                    }
                    Button("后", role: .none) {
                        guard let promotionSide = piecesManager.promotionSide else { return }
                        piecesManager.promotion(to: .q(promotionSide))
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
                    piecesManager.pieces.flatMap { $0 },
                    id: \.id
                ) { model in
                    let index = piecesManager.pieces.flatMap { $0 }.firstIndex { $0.id == model.id }
                    if let index = index {
                        let x = index % 8
                        let y = 7 - index / 8
                        let position = BoardIndex(x: x, y: y)
                        let pieceItem = piecesManager.getPiece(at: position)
                        let isPossibleMove = piecesManager.selectedPiecePossibleMovements.contains { $0.to == position }
                        EquatableView(
                            content: PieceCell(
                                pieceItem: pieceItem,
                                isPossibleMove: isPossibleMove,
                                position: position
                            ) {
                                guard piecesManager.currentSide == pieceItem.side else { return }
                                piecesManager.selectedPieceIndex = position
                            } onMoveIndicatorTapped: {
                                guard let selectedPieceIndex = piecesManager.selectedPieceIndex else { return }
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
            PiecesLayer(piecesManager: PiecesManager())
        }.padding()
    }
}
