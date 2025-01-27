import SwiftUI

struct GuideUI: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple.opacity(1)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Color Match Game Guide")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        .padding(.bottom, 10)
                    
                    // Welcome message
                    Text("Welcome to the Color Match Game! Test your memory and strategy as you match colorful tiles while managing your lifelines. Here's everything you need to know to play and master the game.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                    
                    // Sections
                    GuideSection(title: "Objective", content: [
                        "Match pairs of colored tiles before running out of lifelines. Earn points for every match, avoid penalties for mismatches, and finish the game with a high score."
                    ])
                    
                    GuideSection(title: "How to Play", content: [
                        "1. Starting the Game",
                        "• Tap the Start Game button to begin.",
                        "• A countdown of 3 seconds will reveal all the tile colors. Use this time to memorize their positions.",
                        "• After the countdown, the tiles will be hidden, and the game will start.",
                        "2. Gameplay",
                        "• The grid consists of tiles arranged in a 3x3 layout.",
                        "• Tap on a tile to reveal its color.",
                        "• Match two tiles of the same color to form a pair.",
                        "• If the tiles don't match, they will flip back over after a short delay.",
                        "3. Scoring",
                        "• +10 Points: For every matched pair.",
                        "• -5 Points: For every mismatch.",
                        "• +20 Points: Bonus for each lifeline left at the end of the game.",
                        "• +Extra Points: Earn bonus points based on the time left when you finish the game.",
                        "4. Lifelines",
                        "• You start with 5 lifelines.",
                        "• Lose 1 lifeline for every mismatch.",
                        "• The game ends when you lose all your lifelines or successfully match all pairs."
                    ])
                    
                    GuideSection(title: "Tips for Success", content: [
                        "• Memorize Quickly: Focus on memorizing tile positions during the 3-second countdown.",
                        "• Match Strategically: Try to remember mismatched tile positions to make a match on future turns.",
                        "• Avoid Guessing: Guessing can cost you points and lifelines. Take your time to make calculated moves.",
                        "• Maximize Bonus: Aim to match all pairs while saving as many lifelines as possible to earn a higher score."
                    ])
                    
                    GuideSection(title: "Features", content: [
                        "• High Scores: Your highest scores are saved. Try to beat your previous records!",
                        "• Timer-Based Scoring: Earn additional points based on how quickly you complete the game.",
                        "• Visual Feedback: Lifelines are displayed as hearts. Watch them carefully to track your progress.",
                        "• Dynamic Colors: Enjoy the vibrant and randomized tile colors every time you play."
                    ])
                    
                    GuideSection(title: "Endgame Scenarios", content: [
                        "• Victory: You matched all pairs. Congratulations! Check out your final score and aim higher next time.",
                        "• Game Over: You ran out of lifelines. Don't worry—restart and try again!"
                    ])
                    
                    // Closing message
                    Text("We hope you enjoy the Color Match Game. Have fun, challenge yourself, and train your memory skills! 😊")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Reusable section component
struct GuideSection: View {
    let title: String
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.bottom, 5)
            
            ForEach(content, id: \.self) { line in
                if line.starts(with: "•") || line.starts(with: "1.") || line.starts(with: "2.") || line.starts(with: "3.") || line.starts(with: "4.") {
                    Text(line)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.leading, line.starts(with: "•") ? 20 : 0)
                } else {
                    Text(line)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Material.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
        .padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack {
        GuideUI()
    }
}
