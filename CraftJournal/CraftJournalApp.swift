//
//  CraftJournalApp.swift
//  CraftJournal
//
//  Created by iMac10 on 9/29/26.
//

import SwiftUI

@main
struct CraftJournalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
