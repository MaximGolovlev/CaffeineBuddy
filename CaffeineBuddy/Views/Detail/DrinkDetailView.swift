//
//  DrinkDetailView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI

struct DrinkDetailView: View {
    @StateObject private var viewModel: DrinkDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    private var onDelete: (() -> Void)?
    
    init(drink: CaffeineDrink, onDelete: (() -> Void)?) {
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: DrinkDetailViewModel(drink: drink))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with icon and name
                VStack(spacing: 12) {
                    Image(systemName: viewModel.drink.icon)
                        .font(.system(size: 60))
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Text(viewModel.drink.name)
                        .font(.title)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    Text(viewModel.drink.timestamp, style: .date)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.shared.secondaryColor)
                    
                    Text(viewModel.drink.timestamp, style: .time)
                        .font(.subheadline)
                        .foregroundColor(ThemeManager.shared.secondaryColor)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(16)
                
                // Caffeine information
                VStack(spacing: 16) {
                    Text("Caffeine Content")
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(Int(viewModel.drink.caffeineAmount))")
                                .font(.title2)
                                .foregroundColor(ThemeManager.shared.primaryColor)
                            Text("mg total")
                                .font(.caption)
                                .foregroundColor(ThemeManager.shared.secondaryColor)
                        }
                        
                        if let volume = viewModel.drink.volume {
                            VStack {
                                Text("\(Int(volume))")
                                    .font(.title2)
                                    .foregroundColor(ThemeManager.shared.primaryColor)
                                Text("ml")
                                    .font(.caption)
                                    .foregroundColor(ThemeManager.shared.secondaryColor)
                            }
                        }
                        
                        VStack {
                            Text("\(Int(viewModel.drink.caffeineAmount / (viewModel.drink.volume ?? 100) * 100))")
                                .font(.title2)
                                .foregroundColor(ThemeManager.shared.primaryColor)
                            Text("mg/100ml")
                                .font(.caption)
                                .foregroundColor(ThemeManager.shared.secondaryColor)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(16)
                
                // Clearance progress
                VStack(spacing: 16) {
                    Text("Caffeine Clearance")
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    VStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ThemeManager.shared.surfaceColor)
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isCleared ? Color.green : ThemeManager.shared.primaryColor)
                                .frame(width: CGFloat(viewModel.clearanceProgress) * (UIScreen.main.bounds.width - 80), height: 20)
                        }
                        
                        HStack {
                            Text("Consumed")
                                .font(.caption)
                                .foregroundColor(ThemeManager.shared.secondaryColor)
                            
                            Spacer()
                            
                            Text("Cleared")
                                .font(.caption)
                                .foregroundColor(ThemeManager.shared.secondaryColor)
                        }
                        
                        if viewModel.isCleared {
                            Text("✅ Caffeine has cleared from your system")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .padding(.top, 8)
                        } else {
                            VStack(spacing: 4) {
                                Text("\(Int(viewModel.currentCaffeineLevel)) mg remaining")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeManager.shared.secondaryColor)
                                
                                Text("Estimated clearance in \(viewModel.timeUntilClearance)")
                                    .font(.caption)
                                    .foregroundColor(ThemeManager.shared.tertiaryColor)
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(16)
                
                // Metabolism info
                VStack(spacing: 12) {
                    Text("Metabolism Information")
                        .font(.headline)
                        .foregroundColor(ThemeManager.shared.primaryColor)
                    
                    InfoRow(icon: "clock", title: "Time consumed", value: viewModel.drink.timestamp.formatted(date: .omitted, time: .shortened))
                    InfoRow(icon: "hourglass", title: "Hours passed", value: String(format: "%.1f h", viewModel.hoursSinceConsumption))
                    InfoRow(icon: "timer", title: "Half-life", value: "~5 hours")
                    InfoRow(icon: "brain", title: "Current level", value: "\(Int(viewModel.currentCaffeineLevel)) mg")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(ThemeManager.shared.cardColor)
                .cornerRadius(16)
                
                // Delete button
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Drink")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .background(ThemeManager.shared.backgroundColor.ignoresSafeArea())
        .navigationTitle("Drink Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(ThemeManager.shared.primaryColor)
            }
        }
        .confirmationDialog("Delete Drink", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this \(viewModel.drink.name)?")
        }
        .onAppear {
            viewModel.calculateCurrentMetrics()
        }
    }
}
