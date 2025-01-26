import SwiftUI

struct DifficultySelectionView: View {
    @State private var selectedDifficulty: Difficulty = .easy
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.purple.opacity(1)]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 8) {
                    Text("Choose Your")
                        .font(.system(size: 28, weight: .light, design: .rounded))
                    Text("Challenge Level")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                // Vertical difficulty picker
                VStack(spacing: 20) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        HStack {
                            Text(difficulty.rawValue)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .opacity(selectedDifficulty == difficulty ? 1 : 0)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
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
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                // Start game button
                NavigationLink(destination: ContentView(initialDifficulty: selectedDifficulty)) {
                    HStack {
                        Text("Start Adventure")
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
                    .padding(.horizontal, 30)
                }
                
                // Difficulty descriptions
                VStack(spacing: 10) {
                    Text("What to expect:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(selectedDifficulty.description)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .navigationTitle("Difficulty Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Difficulty {
    var description: String {
        switch self {
        case .easy: return "Perfect for newcomers! A 3x3 grid to learn the basics with plenty of time to memorize."
        case .medium: return "For seasoned players! A 5x5 grid that challenges your memory and speed."
        case .hard: return "Expert mode! A intense 7x7 grid that will test your limits. Only for the brave!"
        }
    }
}

#Preview {
    NavigationStack {
        DifficultySelectionView()
    }
}
