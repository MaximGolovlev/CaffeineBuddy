//
//  DrinkCard.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

struct DrinkCard: View {
    let template: DrinkTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: template.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? ThemeManager.shared.primaryColor : ThemeManager.shared.secondaryColor)
                
                Text(template.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? ThemeManager.shared.primaryColor : ThemeManager.shared.secondaryColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? ThemeManager.shared.cardColor : ThemeManager.shared.surfaceColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? ThemeManager.shared.primaryColor : Color.clear, lineWidth: 2)
            )
        }
    }
}
