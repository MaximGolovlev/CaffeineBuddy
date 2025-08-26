//
//  AnalyticsViewModel.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI
import SwiftData

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var todayCaffeine: Double = 0
    @Published var currentCaffeineLevel: Double = 0
    @Published var clearanceTime: Date?
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        calculateMetrics()
    }
    
    func calculateMetrics() {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<CaffeineDrink>(
            predicate: #Predicate { $0.timestamp >= today },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        do {
            let drinks = try modelContext.fetch(descriptor)
            todayCaffeine = drinks.reduce(0) { $0 + $1.caffeineAmount }
            currentCaffeineLevel = calculateCurrentCaffeineLevel(drinks: drinks)
            clearanceTime = calculateClearanceTime(drinks: drinks)
        } catch {
            print("Failed to fetch drinks for analytics: \(error)")
        }
    }
    
    private func calculateCurrentCaffeineLevel(drinks: [CaffeineDrink]) -> Double {
        let now = Date()
        return drinks.reduce(0) { total, drink in
            let hoursSinceConsumption = now.timeIntervalSince(drink.timestamp) / 3600
            let remaining = drink.caffeineAmount * exp(-hoursSinceConsumption * 0.1386)
            return total + max(0, remaining)
        }
    }
    
    private func calculateClearanceTime(drinks: [CaffeineDrink]) -> Date? {
        guard let lastDrink = drinks.max(by: { $0.timestamp < $1.timestamp }) else { return nil }
        return lastDrink.timestamp.addingTimeInterval(5 * 3600)
    }
}
