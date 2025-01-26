import SwiftUI

struct HomePage: View {
    @Namespace private var animation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple.opacity(0.5)]),
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title and logo
                    VStack(spacing: 20) {
                        Image("1025without")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 50)
                    
                    // Navigation Links
                    VStack(spacing: 20) {
                        NavigationLink(destination: DifficultySelectionView()) {
                            HStack {
                                Text("Start Game")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Image(systemName: "play.fill")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        
                        NavigationLink(destination: HighScoresUI()) {
                            HStack {
                                Text("High Scores")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Image(systemName: "trophy.fill")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]),
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        
                        NavigationLink(destination: GuideUI()) {
                            HStack {
                                Text("Guide")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Image(systemName: "book.fill")
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                             startPoint: .leading,
                                             endPoint: .trailing)
                            )
                            .cornerRadius(15)
                            .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        HomePage()
    }
}
