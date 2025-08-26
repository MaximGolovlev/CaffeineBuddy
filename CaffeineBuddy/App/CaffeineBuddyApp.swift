//
//  CaffeineBuddyApp.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 25.08.2025.
//

import SwiftUI

@main
struct CaffeineBuddyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Persistence.shared.modelContainer)
        
    }
    
//    var body: some Scene {
//        WindowGroup {
//            DeviceListView()
//        }
//    }
}
