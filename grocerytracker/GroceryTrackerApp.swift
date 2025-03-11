//
//  grocerytrackerApp.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//

import SwiftUI
import SwiftData

@main
struct GroceryTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(for: Transaction.self)
    }
}
