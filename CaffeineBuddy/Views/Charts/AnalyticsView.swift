//
//  AnalyticsView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's summary
                VStack(spacing: 12) {
                    Text("Today's Caffeine")
                        .font(.title2)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Text("\(Int(viewModel.todayCaffeine)) mg")
                        .font(.largeTitle)
                        .foregroundColor(ThemeManager.shared.secondaryColor)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(12)
                
                // Current caffeine level
                VStack(spacing: 12) {
                    Text("Current Caffeine Level")
                        .font(.title2)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Text("\(Int(viewModel.currentCaffeineLevel)) mg")
                        .font(.title)
                        .foregroundColor(viewModel.currentCaffeineLevel > 100 ? .orange : ThemeManager.shared.secondaryColor)
                    
                    if let clearanceTime = viewModel.clearanceTime {
                        Text("Estimated clearance: \(clearanceTime, style: .time)")
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.tertiaryColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(12)
                
                // Caffeine timeline chart
                VStack {
                    Text("Caffeine Timeline")
                        .font(.title2)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    TimelineChartView()
                        .frame(height: 200)
                        .padding()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(ThemeManager.shared.backgroundColor.ignoresSafeArea())
        .navigationTitle("Analytics")
        .onAppear {
            viewModel.calculateMetrics()
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(modelContext: ModelContext(Persistence.shared.modelContainer)))
    }
}
