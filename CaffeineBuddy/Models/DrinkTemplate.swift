//
//  DrinkTemplate.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//


struct DrinkTemplate {
    let name: String
    let caffeinePer100ml: Double
    let defaultVolume: Double
    let icon: String
}

extension DrinkTemplate {
    static let coffee = DrinkTemplate(
        name: "Coffee",
        caffeinePer100ml: 40.0,
        defaultVolume: 250.0,
        icon: "cup.and.saucer"
    )
    
    static let tea = DrinkTemplate(
        name: "Tea",
        caffeinePer100ml: 20.0,
        defaultVolume: 200.0,
        icon: "leaf"
    )
    
    static let energyDrink = DrinkTemplate(
        name: "Energy Drink",
        caffeinePer100ml: 32.0,
        defaultVolume: 250.0,
        icon: "bolt"
    )
}