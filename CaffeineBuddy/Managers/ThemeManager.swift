//
//  ThemeManager.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

class ThemeManager {
    static let shared = ThemeManager()
    
    // Warm earthy palette with coral accents
    let primaryColor = Color(red: 0.98, green: 0.45, blue: 0.45)    // Coral red (accent)
    let secondaryColor = Color(red: 0.95, green: 0.77, blue: 0.53)  // Warm sand
    let tertiaryColor = Color(red: 0.55, green: 0.35, blue: 0.25)   // Medium brown (more contrast)
    
    // Layered warm dark backgrounds
    let surfaceColor = Color(red: 0.18, green: 0.14, blue: 0.12)    // Top layer
    let cardColor = Color(red: 0.15, green: 0.11, blue: 0.09)       // Middle layer
    let backgroundColor = Color(red: 0.11, green: 0.08, blue: 0.06) // Deepest layer
    
    private init() {}
}
