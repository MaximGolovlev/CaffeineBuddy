//
//  InfoRow.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ThemeManager.shared.primaryColor)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(ThemeManager.shared.secondaryColor)
            
            Spacer()
            
            Text(value)
                .foregroundColor(ThemeManager.shared.tertiaryColor)
        }
        .font(.subheadline)
        .padding(.vertical, 2)
    }
}
