//
//  Election_Result_DisplayerApp.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/26/25.
//

import SwiftUI

@main
struct Election_Result_DisplayerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
