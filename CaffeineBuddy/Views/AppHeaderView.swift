//
//  AppHeaderView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

// MARK: - App Header View
struct AppHeaderView: View {
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Caffeine Buddy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Text("Track your caffeine intake")
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.shared.secondaryColor)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeManager.shared.primaryColor)
                        .frame(width: 30, height: 30)
                        .background(ThemeManager.shared.cardColor)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(ThemeManager.shared.surfaceColor)
            
            // Expandable description
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "plus.circle.fill",
                        title: "Add Drinks",
                        description: "Track coffee, tea, and energy drinks with volume picker"
                    )
                    
                    FeatureRow(
                        icon: "chart.bar.fill",
                        title: "Analytics",
                        description: "View caffeine timeline and current levels"
                    )
                    
                    FeatureRow(
                        icon: "clock.fill",
                        title: "Smart Tracking",
                        description: "See when caffeine will leave your system"
                    )
                    
                    FeatureRow(
                        icon: "bell.badge.fill",
                        title: "Notifications",
                        description: "Get alerts when caffeine clears"
                    )
                    
                    Text("Goal: Drink smarter, sleep better!")
                        .font(.caption)
                        .italic()
                        .foregroundColor(ThemeManager.shared.tertiaryColor)
                        .padding(.top, 4)
                }
                .padding()
                .background(ThemeManager.shared.cardColor)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(ThemeManager.shared.surfaceColor)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(ThemeManager.shared.primaryColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeManager.shared.primaryColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(ThemeManager.shared.secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
