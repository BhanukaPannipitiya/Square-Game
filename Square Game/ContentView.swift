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
      @State private var matchedPairs: Int = 0
      @State private var showAlert: Bool = false
      @State private var alertMessage: String = ""
      @State private var countdown: Int = 3
      @State private var isCountdownActive: Bool = false
      @State private var isGameStarted: Bool = false
      @State private var score: Int = 0
      @State private var timerValue: Int = 0
      @State private var timer: Timer?
      @State private var playerName: String = ""
      @State private var showNamePrompt: Bool = false
      @State private var currentHighScore: Int = 0
      @State private var currentLevel: Int = 1
      @Namespace private var animation

    init(initialDifficulty: Difficulty) {
            self.initialDifficulty = initialDifficulty
            _difficulty = State(initialValue: initialDifficulty)
        }

        var initialTimeForLevel: Int {
            20 - (currentLevel - 1) * 2
        }

        func tileSize(for gridSize: Int, in geometry: GeometryProxy) -> CGFloat {
            let padding: CGFloat = difficulty == .hard ? 87 : 63
            let screenWidth = geometry.size.width - padding
            let spacing: CGFloat = gridSize > 5 ? 5 : 7
            let totalSpacing = CGFloat(gridSize) * spacing
            let availableWidth = screenWidth - totalSpacing
            return max(availableWidth / CGFloat(gridSize), 40)
        }

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple]),
                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("COLOR MATCH")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        HStack {
                            Text("Level: \(currentLevel)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            
                            Spacer()
                            
                            Text("Time: \(timerValue)")
                                .font(.headline)
                                .monospacedDigit()
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .contentTransition(.numericText())
                                .animation(.easeInOut, value: timerValue)
                        }
                        .padding(.horizontal)
                        
                        if isCountdownActive {
                            Text("Memorize colors in: \(countdown)s!")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .transition(.scale)
                        }
                        
                        Text("Score: \(score)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Material.ultraThinMaterial, in: Capsule())
                            .contentTransition(.numericText())
                        
                        if grid.isEmpty {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(0..<difficulty.gridSize, id: \.self) { row in
                                    HStack(spacing: 10) {
                                        ForEach(0..<difficulty.gridSize, id: \.self) { col in
                                            TileView(
                                                tile: grid[row][col],
                                                size: tileSize(for: difficulty.gridSize, in: geometry),
                                                action: { tileTapped(row: row, col: col) }
                                            )
                                            .disabled(grid[row][col].isRevealed ||
                                                     grid[row][col].isMatched ||
                                                     timerValue == 0 ||
                                                     !isGameStarted)
                                            .matchedGeometryEffect(id: "\(row)-\(col)", in: animation)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        if !isGameStarted {
                            GameButton(
                                text: timerValue == 0 ? "Play Again" : "Start Game",
                                gradient: [.blue, .purple],
                                action: startGameWithCountdown
                            )
                        }
                    }
                    .padding()
                }
            }
            .onAppear(perform: setupGame)
            .alert("Game Over", isPresented: $showAlert) {
                Button("OK", action: setupGame)
            } message: {
                Text(alertMessage)
            }
            .alert("New High Score!", isPresented: $showNamePrompt) {
                TextField("Name", text: $playerName)
                Button("Save", action: saveHighScore)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your name for the hall of fame!")
            }
        }


    func setupGame() {
            let gridSize = difficulty.gridSize
            let pairCount = (gridSize * gridSize - 1) / 2
            var colors = (0..<pairCount).map { _ in randomColor() }
            colors += colors.shuffled()
            colors.append(randomColor())
            colors.shuffle()
            
            grid = (0..<gridSize).map { row in
                (0..<gridSize).map { col in
                    Tile(color: colors[row * gridSize + col])
                }
            }
            
            matchedPairs = 0
            firstSelection = nil
            isGameStarted = false
        }

        func startGameWithCountdown() {
            isCountdownActive = true
            currentLevel = timerValue == 0 ? 1 : currentLevel
            score = timerValue == 0 ? 0 : score
            
            grid.indices.forEach { row in
                grid[row].indices.forEach { col in
                    grid[row][col].isRevealed = true
                }
            }
            
            countdown = 3
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    timer.invalidate()
                    grid.indices.forEach { row in
                        grid[row].indices.forEach { col in
                            grid[row][col].isRevealed = false
                        }
                    }
                    isCountdownActive = false
                    isGameStarted = true
                    timerValue = initialTimeForLevel
                    startTimer()
                }
            }
        }

        func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timerValue > 0 {
                    timerValue -= 1
                } else {
                    timer?.invalidate()
                    checkHighScore()
                    showAlert(message: "Time's up! Score: \(score)")
                }
            }
        }
        func showAlert(message: String) {
            alertMessage = message
            showAlert = true
        }
        func tileTapped(row: Int, col: Int) {
            guard !grid[row][col].isRevealed, !grid[row][col].isMatched else { return }
            
            grid[row][col].isRevealed = true
            
            if let first = firstSelection {
                if grid[first.row][first.col].color == grid[row][col].color {
                    withAnimation {
                        grid[first.row][first.col].isMatched = true
                        grid[row][col].isMatched = true
                    }
                    matchedPairs += 1
                    score += 10
                    timerValue += 2
                    checkLevelCompletion()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            grid[first.row][first.col].isRevealed = false
                            grid[row][col].isRevealed = false
                        }
                    }
                    timerValue = max(timerValue - 5, 0)
                }
                firstSelection = nil
            } else {
                firstSelection = (row, col)
            }
        }

        func checkLevelCompletion() {
            let totalPairsNeeded = (difficulty.gridSize * difficulty.gridSize - 1) / 2
            guard matchedPairs == totalPairsNeeded else { return }
            
            timer?.invalidate()
            score += timerValue * 5
            currentLevel += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                setupGame()
                startGameWithCountdown()
            }
        }

        func checkHighScore() {
            let key = "highScore_\(difficulty.rawValue)"
            let currentHigh = UserDefaults.standard.integer(forKey: key)
            
            if score > currentHigh {
                showNamePrompt = true
            } else {
                UserDefaults.standard.set(score, forKey: key)
            }
        }

    func saveHighScore() {
        let key = "highScores_\(difficulty.rawValue)"
        let newHighScore = HighScore(name: playerName, score: score)
        
        var currentHighScores = highScores(for: difficulty)
        currentHighScores.append(newHighScore)
        
        if let encoded = try? JSONEncoder().encode(currentHighScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        playerName = ""
    }
    func highScores(for difficulty: Difficulty) -> [HighScore] {
        let key = "highScores_\(difficulty.rawValue)"
        if let data = UserDefaults.standard.data(forKey: key),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            return savedScores
        }
        return []
    }

        func randomColor() -> Color {
            Color(red: .random(in: 0...1),
                  green: .random(in: 0...1),
                  blue: .random(in: 0...1))
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
