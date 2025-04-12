//
//  ContentView.swift
//  ChessReviewer
//
//  Created by 方昱恒 on 2025/3/28.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let gameManager = GameManager(
            gameBuilder: InitialGameBuilder(
                gameMode: .pvp, historyControlMode: .playStrict
            )
        )
        if let gameManager = gameManager {
            Game(gameManager: gameManager)
        } else {
            Text("gameBuilder 配置有误")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
