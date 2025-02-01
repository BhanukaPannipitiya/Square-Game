import SwiftUI
import Foundation

struct HighScoresUI: View {
    @State private var highScores: [HighScore] = []
    @State private var selectedDifficulty: Difficulty = .easy
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Matching background gradient from ContentView
            LinearGradient(gradient: Gradient(colors: [
                Color.indigo,
                Color.purple.opacity(1)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title with animation
                Text("High Scores")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .transition(.scale.combined(with: .opacity))
                    .padding()
                
                // Horizontal Difficulty Selection Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            HStack {
                                Text(difficulty.rawValue)
                                    .font(.title2.weight(.semibold))
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .opacity(selectedDifficulty == difficulty ? 1 : 0)
                            }
                            .padding(8)
                            .background(
                                ZStack {
                                    if selectedDifficulty == difficulty {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Material.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                                            .matchedGeometryEffect(id: "difficulty", in: animation)
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedDifficulty == difficulty ? Color.white.opacity(0.4) : Color.clear, lineWidth: 2)
                            )
                            .foregroundColor(selectedDifficulty == difficulty ? .white : .white.opacity(0.7))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDifficulty = difficulty
                                    loadHighScores()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                if highScores.isEmpty {
                    Text("No high scores yet")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .transition(.opacity)
                } else {
                    List(highScores.sorted(by: { $0.score > $1.score })) { highScore in
                        HStack {
                            Text(highScore.name)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Score: \(highScore.score)")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.yellow)
                        }
                        .listRowBackground(Color.clear)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Material.ultraThinMaterial)
                        )
                        .shadow(radius: 5)
                        .transition(.slide)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .padding()
        }
        .onAppear {
            loadHighScores()
        }
    }

    func loadHighScores() {
        let highScoresKey = "highScores_\(selectedDifficulty.rawValue)"
        if let data = UserDefaults.standard.data(forKey: highScoresKey),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = savedScores
        } else {
            highScores = []
        }
    }
}

#Preview {
    HighScoresUI()
}
