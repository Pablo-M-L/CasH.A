//
//  ContentView.swift
//  Shared
//
//  Created by pablo on 11/2/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Servicios.nombreServicio, ascending: true)],
        animation: .default)
    private var servicios: FetchedResults<Servicios>
    var catGeneralCreada = UserDefaults.standard.bool(forKey: "catGeneralCreada")

    var body: some View {
        TabView{
            
            CajaRegistradora()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Cash")
                }
            ListaServicios()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Services")
                }
            
            ListaCategorias(categoriaSeleccionada: .constant("General"))
                .tabItem {
                    Image(systemName: "folder")
                    Text("Categories")
                }
            Historico()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("History")
                }
        }.onAppear{
            if !catGeneralCreada{
                crearCategoriaGeneral(viewcontext: viewContext)
                UserDefaults.standard.setValue(true, forKey: "catGeneralCreada")
            }
        }
    }

//    private func addItem() {
//        withAnimation {
//            let nuevoServicio = Servicios(context: viewContext)
//            nuevoServicio.categoria = "general"
//            nuevoServicio.id = UUID()
//            nuevoServicio.nombreServicio = "cortar pelo"
//            nuevoServicio.precioServicio = 10.50
//
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { servicios[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(helper)
//    }
//}
