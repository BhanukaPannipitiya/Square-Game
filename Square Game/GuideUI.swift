import SwiftUI

struct GuideUI: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Color Match Game Guide")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Welcome to the Color Match Game! Test your memory and strategy as you match colorful tiles while managing your lifelines. Here's everything you need to know to play and master the game.")
                    .font(.body)
                    .padding(.bottom, 10)
                
                Section(header: Text("Objective").font(.title2).fontWeight(.semibold)) {
                    Text("Match pairs of colored tiles before running out of lifelines. Earn points for every match, avoid penalties for mismatches, and finish the game with a high score.")
                }
                
                Section(header: Text("How to Play").font(.title2).fontWeight(.semibold)) {
                    Group {
                        Text("1. Starting the Game")
                            .font(.headline)
                        Text("• Tap the Start Game button to begin.")
                        Text("• A countdown of 3 seconds will reveal all the tile colors. Use this time to memorize their positions.")
                        Text("• After the countdown, the tiles will be hidden, and the game will start.")
                    }
                    .padding(.bottom, 5)
                    
                    Group {
                        Text("2. Gameplay")
                            .font(.headline)
                        Text("• The grid consists of tiles arranged in a 3x3 layout.")
                        Text("• Tap on a tile to reveal its color.")
                        Text("• Match two tiles of the same color to form a pair.")
                        Text("• If the tiles don't match, they will flip back over after a short delay.")
                    }
                    .padding(.bottom, 5)
                    
                    Group {
                        Text("3. Scoring")
                            .font(.headline)
                        Text("• +10 Points: For every matched pair.")
                        Text("• -5 Points: For every mismatch.")
                        Text("• +20 Points: Bonus for each lifeline left at the end of the game.")
                        Text("• +Extra Points: Earn bonus points based on the time left when you finish the game.")
                    }
                    .padding(.bottom, 5)
                    
                    Group {
                        Text("4. Lifelines")
                            .font(.headline)
                        Text("• You start with 5 lifelines.")
                        Text("• Lose 1 lifeline for every mismatch.")
                        Text("• The game ends when you lose all your lifelines or successfully match all pairs.")
                    }
                    .padding(.bottom, 5)
                }
                
                Section(header: Text("Tips for Success").font(.title2).fontWeight(.semibold)) {
                    Text("• Memorize Quickly: Focus on memorizing tile positions during the 3-second countdown.")
                    Text("• Match Strategically: Try to remember mismatched tile positions to make a match on future turns.")
                    Text("• Avoid Guessing: Guessing can cost you points and lifelines. Take your time to make calculated moves.")
                    Text("• Maximize Bonus: Aim to match all pairs while saving as many lifelines as possible to earn a higher score.")
                }
                
                Section(header: Text("Features").font(.title2).fontWeight(.semibold)) {
                    Text("• High Scores: Your highest scores are saved. Try to beat your previous records!")
                    Text("• Timer-Based Scoring: Earn additional points based on how quickly you complete the game.")
                    Text("• Visual Feedback: Lifelines are displayed as hearts. Watch them carefully to track your progress.")
                    Text("• Dynamic Colors: Enjoy the vibrant and randomized tile colors every time you play.")
                }
                
                Section(header: Text("Endgame Scenarios").font(.title2).fontWeight(.semibold)) {
                    Text("• Victory: You matched all pairs. Congratulations! Check out your final score and aim higher next time.")
                    Text("• Game Over: You ran out of lifelines. Don't worry—restart and try again!")
                }
                
                Text("We hope you enjoy the Color Match Game. Have fun, challenge yourself, and train your memory skills! 😊")
                    .font(.body)
                    .padding(.top, 10)
            }
            .padding()
        }
    }
}

#Preview {
    GuideUI()
}
