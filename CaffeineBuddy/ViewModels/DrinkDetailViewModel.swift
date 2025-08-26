//
//  DrinkDetailViewModel.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

@MainActor
class DrinkDetailViewModel: ObservableObject {
    @Published var drink: CaffeineDrink
    @Published var currentCaffeineLevel: Double = 0
    @Published var hoursSinceConsumption: Double = 0
    @Published var isCleared: Bool = false
    
    init(drink: CaffeineDrink) {
        self.drink = drink
        calculateCurrentMetrics()
    }
    
    func calculateCurrentMetrics() {
        let now = Date()
        self.hoursSinceConsumption = now.timeIntervalSince(drink.timestamp) / 3600
        
        // Exponential decay model for caffeine
        self.currentCaffeineLevel = drink.caffeineAmount * exp(-hoursSinceConsumption * 0.1386)
        self.isCleared = currentCaffeineLevel < 10 // Consider cleared if less than 10mg
    }
    
    var clearanceProgress: Double {
        min(1.0, hoursSinceConsumption / 5.0) // 5 hours for full clearance
    }
    
    var estimatedClearanceTime: Date {
        drink.timestamp.addingTimeInterval(5 * 3600) // 5 hours
    }
    
    var timeUntilClearance: String {
        let timeLeft = max(0, estimatedClearanceTime.timeIntervalSince(Date()))
        let hours = Int(timeLeft) / 3600
        let minutes = (Int(timeLeft) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
