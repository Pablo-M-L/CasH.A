//
//  CasH_AApp.swift
//  Shared
//
//  Created by pablo on 7/3/21.
//

import SwiftUI
import Firebase

@main
struct CasH_AApp: App {
    init(){
        FirebaseApp.configure()
    }
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
