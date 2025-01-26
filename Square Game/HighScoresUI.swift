import SwiftUI
import Foundation

struct HighScoresUI: View {
    @State private var highScores: [HighScore] = []

    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .padding()

            if highScores.isEmpty {
                Text("No high scores yet")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List(highScores.sorted(by: { $0.score > $1.score })) { highScore in
                    HStack {
                        Text(highScore.name)
                            .font(.title2)
                        Spacer()
                        Text("Score: \(highScore.score)")
                            .font(.title2)
                    }
                }
            }
        }
        .padding()
        .background(Color.primary.colorInvert().opacity(0.75))
        .cornerRadius(10)
        .onAppear {
            loadHighScores()
        }
    }

    func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: "highScores"),
           let savedScores = try? JSONDecoder().decode([HighScore].self, from: data) {
            highScores = savedScores
        }
    }
}

#Preview {
    HighScoresUI()
}
