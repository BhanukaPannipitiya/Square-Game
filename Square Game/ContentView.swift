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
    @Namespace private var animation

    init(initialDifficulty: Difficulty) {
        self.initialDifficulty = initialDifficulty
        _difficulty = State(initialValue: initialDifficulty)
    }

    func tileSize(for gridSize: Int, in geometry: GeometryProxy) -> CGFloat {
        let padding: CGFloat
        switch difficulty {
        case .easy: padding = 63
        case .medium: padding = 63
        case .hard: padding = 87
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
                // Enhanced background gradient
                LinearGradient(gradient: Gradient(colors: [
                    Color.indigo,
                    Color.purple.opacity(1)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Animated title
                    Text("COLOR MATCH")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.top, 20)
                        .transition(.scale.combined(with: .opacity))
                    
                    // Status HStack with animated elements
                    HStack {
                        if isGameStarted {
                            Text("Time: \(timerValue) sec")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .transition(.opacity)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            VStack {
                                Spacer() // Pushes content down

                                HStack {
                                    Spacer() // Pushes content to the left

                                    HStack(spacing: 10) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: index < lifelines ? "heart.fill" : "heart")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(index < lifelines ? .red : .white.opacity(0.3))
                                                .symbolEffect(.bounce, value: lifelines)
                                                .transition(.scale.combined(with: .opacity))
                                        }
                                    }

                                    Spacer() // Pushes content to the right
                                }

                                Spacer() // Pushes content up
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Game messages with animations
                    Group {
                        if lifelines == 5 {
                            Text("You are full of life! 💖")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .transition(.slide)
                        } else if !lostLifeMessage.isEmpty {
                            Text(lostLifeMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .transition(.asymmetric(
                                    insertion: .push(from: .top),
                                    removal: .push(from: .bottom)
                                ))
                        }
                        
                        if isCountdownActive {
                            Text("Memorize colors in: \(countdown)s!")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(), value: lostLifeMessage)
                    
                    // Score display with animation
                    Text("Score: \(score)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Material.ultraThinMaterial, in: Capsule())
                        .contentTransition(.numericText())
                        .animation(.bouncy, value: score)
                    
                    // Game grid with enhanced animations
                    if grid.isEmpty {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                            .tint(.white)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(0..<difficulty.gridSize, id: \.self) { row in
                                HStack(spacing: 10) {
                                    ForEach(0..<difficulty.gridSize, id: \.self) { col in
                                        let tile = grid[row][col]
                                        TileView(
                                            tile: tile,
                                            size: tileSize(for: difficulty.gridSize, in: geometry),
                                            action: { tileTapped(row: row, col: col) }
                                        )
                                        .disabled(tile.isRevealed || tile.isMatched || lifelines == 0 || !isGameStarted)
                                        .matchedGeometryEffect(id: "\(row)-\(col)", in: animation, isSource: !tile.isMatched)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    // Enhanced game buttons
                    if !isGameStarted {
                        GameButton(
                            text: "Start Game",
                            gradient: [Color.blue, Color.purple],
                            action: startGameWithCountdown
                        )
                        .padding(.vertical)
                        .transition(.scale.combined(with: .opacity))
                    } else if lifelines == 0 || matchedPairs == (difficulty.gridSize * difficulty.gridSize - 1) / 2 {
                        GameButton(
                            text: "Restart Game",
                            gradient: [Color.green, Color.mint],
                            action: setupGame
                        )
                        .padding(.vertical)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
            }
        }
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

    // MARK: - Game Logic
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

// MARK: - Subviews with Enhanced Animations
struct TileView: View {
    let tile: Tile
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tile.isRevealed || tile.isMatched ? tile.color : Color.gray.opacity(0.5))
                    .frame(width: size, height: size)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing),
                                lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(tile.isMatched ? 0.3 : 0.2), radius: 5, x: 2, y: 2)
                
                if tile.isMatched {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.4, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(SpringButtonStyle())
        .rotationEffect(.degrees(tile.isMatched ? 360 : 0))
        .scaleEffect(tile.isRevealed ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tile.isRevealed)
        .animation(.bouncy(duration: 0.5), value: tile.isMatched)
    }
}

struct GameButton: View {
    let text: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: gradient.first?.opacity(0.4) ?? .blue, radius: 10, x: 0, y: 5)
                )
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - Custom Button Styles
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView(initialDifficulty: .hard)
}
