//
//  ContentView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 25.08.2025.
//

import SwiftUI
import SwiftData
import Charts
import UserNotifications

struct ContentView: View {
    var body: some View {
        TabView {
            CaffeineListView()
                .tabItem {
                    Label("Tracker", systemImage: "cup.and.saucer")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
        }
        .accentColor(ThemeManager.shared.primaryColor)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Persistence


#Preview {
    ContentView()
}
