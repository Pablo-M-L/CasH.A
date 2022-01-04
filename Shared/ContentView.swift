//
//  ContentView.swift
//  Shared
//
//  Created by pablo on 7/3/21.
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
                    Image(systemName: "text.book.closed")
                    Text("Services")
                }
            
            ListaCategorias(categoriaSeleccionada: .constant("General"))
                .tabItem {
                    Image(systemName: "tag.circle")
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
