//
//  HighScoresUI.swift
//  Square Game
//
//  Created by Bhanuka  Pannipitiya  on 2025-01-05.
//

import SwiftUI

struct HighScoresUI: View {
    // Retrieve high scores from UserDefaults
    @State private var highScores: [Int] = UserDefaults.standard.array(forKey: "highScores") as? [Int] ?? []

    var body: some View {
        VStack {
            Text("High Scores")
                .font(.largeTitle)
                .padding()

            // Display the top 5 scores
            if highScores.isEmpty {
                Text("No high scores yet")
                    .font(.headline)
                    .foregroundColor(.gray)
            } else {
                List(highScores, id: \.self) { score in
                    Text("Score: \(score)")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color.primary.colorInvert().opacity(0.75))
        .cornerRadius(10)
    }
}

#Preview {
    HighScoresUI()
}

