//
//  ZeroDayChessMasterApp.swift
//  ZeroDayChessMaster
//
//  Created by Ugonna Oparaochaekwe on 11/22/23.
//

import SwiftUI
import SwiftData

@main
struct ZeroDayChessMasterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
