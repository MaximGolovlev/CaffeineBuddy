//
//  CaffeineDrink.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftData
import Foundation

@Model
class CaffeineDrink {
    var id: UUID
    var name: String
    var caffeineAmount: Double // in mg
    var timestamp: Date
    var volume: Double? // in ml
    
    init(id: UUID = UUID(), name: String, caffeineAmount: Double, timestamp: Date = Date(), volume: Double? = nil) {
        self.id = id
        self.name = name
        self.caffeineAmount = caffeineAmount
        self.timestamp = timestamp
        self.volume = volume
    }
    
    var icon: String {
        switch name {
        case "Coffee": return "cup.and.saucer"
        case "Tea": return "leaf"
        case "Energy Drink": return "bolt"
        default: return "cup.and.saucer"
        }
    }
}
