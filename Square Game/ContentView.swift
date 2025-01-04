
import SwiftUI

struct Tile {
    var color: Color
    var isRevealed: Bool = false
    var isMatched: Bool = false
}

struct ContentView: View {
        @State private var grid: [[Tile]] = []
        @State private var firstSelection: (row: Int, col: Int)? = nil
        @State private var score: Int = 0
        @State private var showFailure: Bool = false
        @State private var showWin: Bool = false
    
        let gridSize = 3
    var body: some View {
        VStack {
            Text("Memory match game")
                .font(.system(size: 32,weight: .medium,design: .default))
                .foregroundColor(.indigo)
                .padding()
            Text("Score: \(score)")
                .font(.title)
                .foregroundColor(.white)
                .padding()

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
