import SwiftUI
import Foundation

struct Tile {
    var color: Color
    var isRevealed: Bool = false
    var isMatched: Bool = false
}

struct ContentView: View {
        let initialDifficulty: Difficulty
        @State private var difficulty: Difficulty
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
        @State private var score: Int = 0
        @State private var timerValue: Int = 0
        @State private var timer: Timer?
        @State private var playerName: String = ""
        @State private var showNamePrompt: Bool = false
        @State private var currentHighScore: Int = 0

    init(initialDifficulty: Difficulty) {
        self.initialDifficulty = initialDifficulty
        _difficulty = State(initialValue: initialDifficulty)
    }
    
    func tileSize(for gridSize: Int, in geometry: GeometryProxy) -> CGFloat {
        let padding: CGFloat
        switch difficulty {
        case .easy:
            padding = 30
        case .medium:
            padding = 40
        case .hard:
            padding = 60
        }
        
        let screenWidth = geometry.size.width - padding
        let spacing: CGFloat = gridSize > 5 ? 5 : 7
        let totalSpacing = CGFloat(gridSize) * spacing
        let availableWidth = screenWidth - totalSpacing
        return max(availableWidth / CGFloat(gridSize), 40)
    }

    var body: some View {
            GeometryReader { geometry in
                
                ZStack {
                    VStack {
                        Text("COLOR MATCH")
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding()

                        if isGameStarted {
                            Text("Time: \(timerValue) sec")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.bottom, 10)
                        }

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

                        if isCountdownActive {
                            Text("You have \(countdown) seconds to memorize the colors!")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.bottom, 10)
                        }

                        Text("Score: \(score)")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.bottom, 10)

                        Spacer()

                        if grid.isEmpty {
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                        } else {
                            VStack(spacing: 10) {
                                ForEach(0..<difficulty.gridSize, id: \.self) { row in
                                    HStack(spacing: 10) {
                                        ForEach(0..<difficulty.gridSize, id: \.self) { col in
                                            let tile = grid[row][col]
                                            Button(action: {
                                                tileTapped(row: row, col: col)
                                            }) {
                                                Rectangle()
                                                    .fill(tile.isRevealed || tile.isMatched ? tile.color : Color.gray)
                                                    .frame(
                                                        width: self.tileSize(
                                                            for: difficulty.gridSize,
                                                            in: geometry
                                                        ),
                                                        height: self.tileSize(
                                                            for: difficulty.gridSize,
                                                            in: geometry
                                                        )
                                                    )
                                                    .cornerRadius(8)
                                                    .shadow(radius: 3)
                                            }
                                            .disabled(tile.isRevealed || tile.isMatched || lifelines == 0 || !isGameStarted)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
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
                        } else if lifelines == 0 || matchedPairs == (difficulty.gridSize * difficulty.gridSize - 1) / 2 {
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
                .background(Color.primary.colorInvert().opacity(0.75))
                .onAppear {
                    setupGame()
                    loadCurrentHighScore()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(alertMessage),
                        message: Text(alertMessage.contains("Congratulations") ?
                                     "You matched all the colors!" : "Game Over!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert("New High Score!", isPresented: $showNamePrompt) {
                    TextField("Enter Your Name", text: $playerName)
                    Button("Save", action: saveHighScore)
                }
            }
        }

    func setupGame() {
            let gridSize = difficulty.gridSize
            let pairCount = (gridSize * gridSize - 1) / 2
            var colors = (0..<pairCount).map { _ in randomColor() }
            colors += colors
            colors.append(randomColor())
            colors.shuffle()

            grid = (0..<gridSize).map { row in
                (0..<gridSize).map { col in
                    Tile(color: colors[row * gridSize + col])
                }
            }

            score = 0
            lifelines = 5
            matchedPairs = 0
            firstSelection = nil
            lostLifeMessage = ""
            isGameStarted = false
            timerValue = 0
            timer?.invalidate()
        }


    func startGameWithCountdown() {
            isCountdownActive = true
            isGameStarted = false

            for row in 0..<difficulty.gridSize {
                for col in 0..<difficulty.gridSize {
                    grid[row][col].isRevealed = true
                }
            }

            countdown = 3
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if self.countdown > 0 {
                    self.countdown -= 1
                } else {
                    timer.invalidate()
                    for row in 0..<self.difficulty.gridSize {
                        for col in 0..<self.difficulty.gridSize {
                            self.grid[row][col].isRevealed = false
                        }
                    }
                    self.isCountdownActive = false
                    self.isGameStarted = true
                    self.startTimer()
                }
            }
        }
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerValue += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func tileTapped(row: Int, col: Int) {
        guard row < difficulty.gridSize, col < difficulty.gridSize else { return }

        grid[row][col].isRevealed = true

        if let first = firstSelection {
            if grid[first.row][first.col].color == grid[row][col].color {
                grid[first.row][first.col].isMatched = true
                grid[row][col].isMatched = true
                matchedPairs += 1
                score += 10
                checkGameOver()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    grid[first.row][first.col].isRevealed = false
                    grid[row][col].isRevealed = false
                }
                lifelines -= 1
                score -= 5
                lostLifeMessage = "You lost one life!"
                if lifelines == 0 {
                    showGameOverAlert()
                }
            }
            firstSelection = nil
        } else {
            firstSelection = (row, col)
        }
    }

    func checkGameOver() {
        let gridSize = difficulty.gridSize
        if matchedPairs == (gridSize * gridSize - 1) / 2 {
            stopTimer()
            score += max(100 - timerValue, 0)
            
            let highScoreKey = "currentHighScore_\(difficulty.rawValue)"
            let currentHighScore = UserDefaults.standard.integer(forKey: highScoreKey)
            
            if score > currentHighScore {
                showNamePrompt = true
            } else {
                saveAnonymousScore()
                showGameOverAlert()
            }
        }
    }
    
    func saveAnonymousScore() {
        let highScoresKey = "highScores_\(difficulty.rawValue)"
        var highScores: [HighScore] = []
        
        if let data = UserDefaults.standard.data(forKey: highScoresKey),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = savedScores
        }
        
        let anonymousScore = HighScore(name: "Anonymous", score: score)
        highScores.append(anonymousScore)
        
        if let encodedData = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encodedData, forKey: highScoresKey)
        }
    }

    func saveHighScore() {
        let highScoresKey = "highScores_\(difficulty.rawValue)"
        let highScoreKey = "currentHighScore_\(difficulty.rawValue)"
        
        var highScores: [HighScore] = []
        
        if let data = UserDefaults.standard.data(forKey: highScoresKey),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = savedScores
        }
        
        let newHighScore = HighScore(name: playerName.isEmpty ? "Anonymous" : playerName, score: score)
        highScores.append(newHighScore)
        
        UserDefaults.standard.set(score, forKey: highScoreKey)
        
        if let encodedData = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encodedData, forKey: highScoresKey)
        }
        
        showGameOverAlert()
    }

    func loadCurrentHighScore() {
        let highScoreKey = "currentHighScore_\(difficulty.rawValue)"
        currentHighScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func showGameOverAlert() {
        showAlert(message: "Game Over! Final Score: \(score)")
    }

    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    func randomColor() -> Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}

#Preview {
    ContentView(initialDifficulty: .hard)
}
