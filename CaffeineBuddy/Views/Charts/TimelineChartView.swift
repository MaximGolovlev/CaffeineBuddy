//
//  TimelineChartView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI
import Charts
import SwiftData

struct TimelineChartView: View {
    @Query(sort: \CaffeineDrink.timestamp) private var drinks: [CaffeineDrink]
    
    var body: some View {
        Chart {
            ForEach(drinks.filter { isToday($0.timestamp) }) { drink in
                BarMark(
                    x: .value("Time", drink.timestamp, unit: .hour),
                    y: .value("Caffeine", drink.caffeineAmount)
                )
                .foregroundStyle(ThemeManager.shared.primaryColor.gradient)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisGridLine()
                    .foregroundStyle(ThemeManager.shared.tertiaryColor)
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, style: .time)
                            .foregroundColor(ThemeManager.shared.secondaryColor)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(ThemeManager.shared.tertiaryColor)
                AxisValueLabel()
                  //.foregroundColor(ThemeManager.shared.secondaryColor)
            }
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
