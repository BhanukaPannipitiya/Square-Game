//
//  DifficultyEnum.swift
//  Square Game
//
//  Created by Bhanuka  Pannipitiya  on 2025-01-26.
//

import Foundation

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var gridSize: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
}
