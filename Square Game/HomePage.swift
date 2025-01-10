//
//  HomePage.swift
//  Square Game
//
//  Created by Bhanuka  Pannipitiya  on 2025-01-05.
//

import SwiftUI

struct HomePage: View {

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
            
        }
    }

    
}

#Preview {
    HomePage()
}
