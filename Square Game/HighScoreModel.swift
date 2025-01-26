//
//  HighScoreModel.swift
//  Square Game
//
//  Created by Bhanuka  Pannipitiya  on 2025-01-26.
//

import Foundation

struct HighScore: Codable, Identifiable {
    let id: UUID
    let name: String
    let score: Int
    
    init(id: UUID = UUID(), name: String, score: Int) {
        self.id = id
        self.name = name
        self.score = score
    }
}
