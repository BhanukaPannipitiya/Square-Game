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
    @State private var score: Int = UserDefaults.standard.integer(forKey: "score") // Retrieve stored score

    let gridSize = 3

    var body: some View {
        ZStack {
            VStack {
                Text("COLOR MATCH")
                    .font(.system(size: 32, weight: .bold, design:.monospaced))
                    .foregroundColor(.black)
                    .padding()

                HStack {
                    ForEach(0..<5, id: \.self) { index in
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

                // Display countdown message
                if isCountdownActive {
                    Text("You have \(countdown) seconds to memorize the colors!")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                }

                // Display score
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)

                Spacer()

                // Grid content
                if grid.isEmpty {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    VStack(spacing: 10) {
                        ForEach(0..<gridSize, id: \.self) { row in
                            HStack(spacing: 10) {
                                ForEach(0..<gridSize, id: \.self) { col in
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

                // Game control buttons
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
        let pairCount = (gridSize * gridSize - 1) / 2
        let colors = (0..<pairCount).map { _ in randomColor() }
        var allColors = (colors + colors).shuffled()

        allColors.append(randomColor())

        grid = (0..<gridSize).map { row in
            (0..<gridSize).map { col in
                Tile(color: allColors[row * gridSize + col])
            }
        }
        score = 0
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
        grid[row][col].isRevealed = true

        if let first = firstSelection {
            if grid[first.row][first.col].color == grid[row][col].color {
                grid[first.row][first.col].isMatched = true
                grid[row][col].isMatched = true
                matchedPairs += 1
                score += 10 // Reward for a correct match
                UserDefaults.standard.set(score, forKey: "score")
                checkGameOver()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    grid[first.row][first.col].isRevealed = false
                    grid[row][col].isRevealed = false
                }
                lifelines -= 1
                score -= 5 // Penalty for an incorrect match
                lostLifeMessage = "You lost one life!"
                if lifelines == 0 {
                    showAlert(message: "Game Over! Final Score: \(score)")
                }
            }
            firstSelection = nil
        } else {
            firstSelection = (row, col)
        }
    }


    func checkGameOver() {
        let pairCount = (gridSize * gridSize - 1) / 2
        if matchedPairs == pairCount {
            // Add bonus points for remaining lives
            score += lifelines * 20
            UserDefaults.standard.set(score, forKey: "score")
            updateHighScores()
            showAlert(message: "Congratulations! Final Score: \(score)")
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
    
    func updateHighScores() {
        var highScores = UserDefaults.standard.array(forKey: "highScores") as? [Int] ?? []

        // Add the new score to the high scores array
        highScores.append(score)

        // Sort the array in descending order and take only the top 5 scores
        highScores.sort(by: >)
        highScores = Array(highScores.prefix(5))

        // Save the updated high scores list back to UserDefaults
        UserDefaults.standard.set(highScores, forKey: "highScores")
        
        
        print("Updated High Scores: \(highScores)")
    }

}

#Preview {
    ContentView()
}
