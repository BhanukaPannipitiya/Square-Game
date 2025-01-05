import SwiftUI

struct Tile {
    var color: Color
    var isRevealed: Bool = false
    var isMatched: Bool = false
}

struct ContentView: View {
    @State private var grid: [[Tile]] = []
    @State private var firstSelection: (row: Int, col: Int)? = nil
    @State private var lifelines: Int = 5
    @State private var matchedPairs: Int = 0
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var lostLifeMessage: String = ""
    @State private var countdown: Int = 3
    @State private var isCountdownActive: Bool = false
    @State private var isGameStarted: Bool = false

    let gridSize = 3 // 3x3 grid

    var body: some View {
        ZStack {
            VStack {
                Text("COLOR MATCH")
                    .font(.system(size: 32, weight: .bold, design:.monospaced))
                    .foregroundColor(.black)
                    .padding()

                HStack {
                    ForEach(0..<5, id: \ .self) { index in
                        Image(systemName: index < lifelines ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(index < lifelines ? .red : .black)
                    }
                }
                .padding()

                if lifelines == 5 {
                    Text("You are full of life")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.bottom, 10)
                } else if !lostLifeMessage.isEmpty {
                    Text(lostLifeMessage)
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }

                if isCountdownActive {
                    Text("You have \(countdown) seconds to memorize the colors!")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                }

                Spacer()

                if grid.isEmpty {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    VStack(spacing: 10) {
                        ForEach(0..<gridSize, id: \ .self) { row in
                            HStack(spacing: 10) {
                                ForEach(0..<gridSize, id: \ .self) { col in
                                    let tile = grid[row][col]
                                    Button(action: {
                                        tileTapped(row: row, col: col)
                                    }) {
                                        Rectangle()
                                            .fill(tile.isRevealed || tile.isMatched ? tile.color : Color.gray)
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    }
                                    .disabled(tile.isRevealed || tile.isMatched || lifelines == 0 || !isGameStarted)
                                }
                            }
                        }
                    }
                }

                Spacer()

                if !isGameStarted {
                    Button("Start Game") {
                        startGameWithCountdown()
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                } else if lifelines == 0 || matchedPairs == (gridSize * gridSize - 1) / 2 {
                    Button("Restart Game") {
                        setupGame()
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        }
        .background(Color.primary
            .colorInvert()
            .opacity(0.75))
        .onAppear {
            setupGame()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage),
                message: Text(alertMessage == "Congratulations!" ? "You matched all the colors!" : "Game Over!"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    func setupGame() {
        let pairCount = (gridSize * gridSize - 1) / 2 // Number of pairs (4 pairs for 3x3 grid)
        let colors = (0..<pairCount).map { _ in randomColor() }
        var allColors = (colors + colors).shuffled()

        // Add one extra tile as a "neutral" tile
        allColors.append(randomColor())

        // Populate the grid with shuffled colors
        grid = (0..<gridSize).map { row in
            (0..<gridSize).map { col in
                Tile(color: allColors[row * gridSize + col])
            }
        }

        lifelines = 5
        matchedPairs = 0
        firstSelection = nil
        lostLifeMessage = ""
        isGameStarted = false
    }

    func startGameWithCountdown() {
        isCountdownActive = true
        isGameStarted = false

        // Reveal all tiles during countdown
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                grid[row][col].isRevealed = true
            }
        }

        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                // Hide all tiles after countdown
                for row in 0..<gridSize {
                    for col in 0..<gridSize {
                        grid[row][col].isRevealed = false
                    }
                }
                isCountdownActive = false
                isGameStarted = true
            }
        }
    }

    func tileTapped(row: Int, col: Int) {
        // Reveal the tile
        grid[row][col].isRevealed = true

        if let first = firstSelection {
            // Check if the second selection matches the first
            if grid[first.row][first.col].color == grid[row][col].color {
                // Matched
                grid[first.row][first.col].isMatched = true
                grid[row][col].isMatched = true
                matchedPairs += 1 // Increment matched pairs counter
                checkGameOver()
            } else {
                // Not matched
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    grid[first.row][first.col].isRevealed = false
                    grid[row][col].isRevealed = false
                }
                lifelines -= 1
                lostLifeMessage = "You lost one life!"
                if lifelines == 0 {
                    showAlert(message: "Game Over!")
                }
            }
            firstSelection = nil
        } else {
            // Store the first selection
            firstSelection = (row, col)
        }
    }

    func checkGameOver() {
        let pairCount = (gridSize * gridSize - 1) / 2
        if matchedPairs == pairCount {
            showAlert(message: "Congratulations!")
        }
    }

    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    func randomColor() -> Color {
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
}

#Preview {
    ContentView()
}
