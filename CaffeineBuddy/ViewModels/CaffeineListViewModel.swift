//
//  CaffeineListViewModel.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

import SwiftUI
import SwiftData

@MainActor
class CaffeineListViewModel: ObservableObject {
    @Published var drinks: [CaffeineDrink] = []
    @Published var selectedTemplate: DrinkTemplate = .coffee
    @Published var selectedVolume: Double = 250.0
    
    var volumeOptions: [VolumeOption] {
        [100, 150, 200, 250, 300, 350, 400, 500].map { VolumeOption(value: $0) }
    }
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchDrinks()
    }
    
    func fetchDrinks() {
        let descriptor = FetchDescriptor<CaffeineDrink>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            drinks = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch drinks: \(error)")
        }
    }
    
    func addDrink() {
        let caffeineAmount = (selectedTemplate.caffeinePer100ml * selectedVolume) / 100.0
        let drink = CaffeineDrink(
            name: selectedTemplate.name,
            caffeineAmount: caffeineAmount,
            volume: selectedVolume
        )
        
        modelContext.insert(drink)
        
        do {
            try modelContext.save()
            fetchDrinks()
           // scheduleNotification(for: drink)
        } catch {
            print("Failed to save drink: \(error)")
        }
    }
    
    func deleteDrink(_ drink: CaffeineDrink) {
        modelContext.delete(drink)
        do {
            try modelContext.save()
            fetchDrinks()
        } catch {
            print("Failed to delete drink: \(error)")
        }
    }
    
    private func scheduleNotification(for drink: CaffeineDrink) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let notificationTime = drink.timestamp.addingTimeInterval(5 * 3600)
                
                let content = UNMutableNotificationContent()
                content.title = "Caffeine Cleared! ☕️"
                content.body = "Your \(drink.name) has likely left your system. Time for another?"
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime),
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: drink.id.uuidString,
                    content: content,
                    trigger: trigger
                )
                
                center.add(request)
            }
        }
    }
}
