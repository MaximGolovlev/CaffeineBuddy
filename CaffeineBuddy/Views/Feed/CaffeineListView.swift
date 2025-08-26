//
//  CaffeineListView.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI
import SwiftData

struct CaffeineListView: View {
    @StateObject private var viewModel: CaffeineListViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                drinkSelector
                
                if viewModel.drinks.isEmpty {
                    EmptyDrinksView()
                } else {
                    drinksList
                }
            }
        }
        .navigationTitle("Caffeine Tracker")
        .background(ThemeManager.shared.backgroundColor.ignoresSafeArea())
        .onAppear {
            viewModel.fetchDrinks()
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: CaffeineListViewModel(modelContext: ModelContext(Persistence.shared.modelContainer)))
    }
    
    private var drinkSelector: some View {
        
        VStack(spacing: 16) {
            
            Text("Select Your Drink")
                .font(.headline)
                .foregroundColor(ThemeManager.shared.primaryColor)
                .padding(.top)
            
            HStack(spacing: 12) {
                DrinkCard(
                    template: .coffee,
                    isSelected: viewModel.selectedTemplate.name == "Coffee",
                    action: { viewModel.selectedTemplate = .coffee }
                )
                
                DrinkCard(
                    template: .tea,
                    isSelected: viewModel.selectedTemplate.name == "Tea",
                    action: { viewModel.selectedTemplate = .tea }
                )
                
                DrinkCard(
                    template: .energyDrink,
                    isSelected: viewModel.selectedTemplate.name == "Energy Drink",
                    action: { viewModel.selectedTemplate = .energyDrink }
                )
            }
            .padding(.horizontal)
            
            HStack {
                volumeSelector
                    .padding(.horizontal)
                Text("Caffeine: \(Int((viewModel.selectedTemplate.caffeinePer100ml * viewModel.selectedVolume) / 100.0)) mg")
                    .font(.subheadline)
                    .foregroundColor(ThemeManager.shared.secondaryColor)
                    .padding(.horizontal)
            }
            
            // Add drink button
            Button(action: viewModel.addDrink) {
                Text("Add \(viewModel.selectedTemplate.name)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeManager.shared.primaryColor)
                    .foregroundColor(ThemeManager.shared.backgroundColor)
                    .font(.headline)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(ThemeManager.shared.surfaceColor)
    
    }
    
    private var volumeSelector: some View {
        
        Menu {
            ForEach(viewModel.volumeOptions) { volume in
                Button(action: {
                    viewModel.selectedVolume = volume.value
                }) {
                    HStack {
                        Text("\(Int(volume.value)) ml")
                        Spacer()
                        Text("\(Int((viewModel.selectedTemplate.caffeinePer100ml * volume.value) / 100.0)) mg")
                            .font(.caption)
                            .foregroundColor(ThemeManager.shared.secondaryColor)
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(ThemeManager.shared.primaryColor)

                Text("Volume: \(Int(viewModel.selectedVolume)) ml")
                    .foregroundColor(ThemeManager.shared.primaryColor)

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(ThemeManager.shared.secondaryColor)
            }
            .padding()
            .background(ThemeManager.shared.cardColor)
            .cornerRadius(10)
        }
    }
    
    private var drinksList: some View {
        List {
            ForEach(viewModel.drinks) { drink in
                DrinkRow(drink: drink, onDelete: {
                    viewModel.deleteDrink(drink)
                })
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteDrink(drink)
                    }
                }
                .listRowBackground(ThemeManager.shared.cardColor)
            }
        }
        .listStyle(PlainListStyle())
        .background(ThemeManager.shared.backgroundColor)
    }
}
