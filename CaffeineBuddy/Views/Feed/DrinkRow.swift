//
//  DrinkRow.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

struct DrinkRow: View {
    let drink: CaffeineDrink
    @State private var showDetail = false
    var onDelete: (() -> Void)?
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(drink.name)
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Spacer()
                    
                    if let volume = drink.volume {
                        Text("\(Int(volume)) ml")
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.tertiaryColor)
                    }
                }
                
                Text("\(Int(drink.caffeineAmount)) mg caffeine")
                    .foregroundColor(ThemeManager.shared.secondaryColor)
                
                Text(drink.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.tertiaryColor)
            }
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showDetail) {
            NavigationView {
                DrinkDetailView(drink: drink, onDelete: onDelete)
            }
        }
    }
}
