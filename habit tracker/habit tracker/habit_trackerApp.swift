//
//  habit_trackerApp.swift
//  habit tracker
//
//  Created by Ali Erdem Kökcik on 6.11.2022.
//

import SwiftUI

@main
struct habit_trackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
