//
//  HectorBarberApp.swift
//  Shared
//
//  Created by pablo on 11/2/21.
//

import SwiftUI

@main
struct HectorBarberApp: App {
    let persistenceController = PersistenceController.shared

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
    }
}
