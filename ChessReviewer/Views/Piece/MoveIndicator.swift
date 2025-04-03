//
//  MoveIndicator.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/29.
//

import SwiftUI

struct MoveIndicator: View {
    let targetIndex: BoardIndex
    let onMoveIndicatorTapped: (() -> Void)
    
    var body: some View {
        Button {
            onMoveIndicatorTapped()
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                Circle()
                    .frame(width: 14)
                    .foregroundColor(Color(hex: "#aaaaaa"))
                    .opacity(0.6)
            }
        }
    }
}

struct MoveIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MoveIndicator(targetIndex: BoardIndex.getOriginIndex()) {}
        }
        .frame(width: 200, height: 200)
        .background(.blue)
    }
}
