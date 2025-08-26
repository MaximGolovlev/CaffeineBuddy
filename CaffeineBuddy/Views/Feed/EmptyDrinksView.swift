//
//  EmptyDrinksView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

struct EmptyDrinksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 60))
                .foregroundColor(ThemeManager.shared.secondaryColor)
            
            VStack(spacing: 8) {
                Text("No Drinks Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeManager.shared.primaryColor)
                
                Text("Start tracking your caffeine intake by adding your first drink!")
                    .font(.body)
                    .foregroundColor(ThemeManager.shared.secondaryColor)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemeManager.shared.backgroundColor)
    }
}
