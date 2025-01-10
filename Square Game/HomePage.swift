//
//  HomePage.swift
//  Square Game
//
//  Created by Bhanuka  Pannipitiya  on 2025-01-05.
//

import SwiftUI

struct HomePage: View {
    @State private var highScores: [Int] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Color Matching Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Image("1024")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 90)
                }

                // High Scores Section
                VStack(alignment: .leading) {
                    Text("High Scores")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(highScores, id: \.self) { score in
                        Text("• \(score)")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)

                // Navigation Links
                NavigationLink(destination: ContentView()) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                NavigationLink(destination: HighScoresUI()) {
                    Text("High Scores")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

                NavigationLink(destination: GuideUI()) {
                    Text("Guide")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: loadHighScores) // Load high scores when the view appears
        }
    }

    // Method to load high scores
    private func loadHighScores() {
        highScores = UserDefaults.standard.array(forKey: "highScores") as? [Int] ?? []
    }
}

#Preview {
    HomePage()
}
