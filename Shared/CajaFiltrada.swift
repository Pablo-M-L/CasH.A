//
//  CajaFiltrada.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//


import SwiftUI
import CoreData

struct CajaFiltrada: View {

    var fetchRequest: FetchRequest<Servicios>

    @State private var sumaTotal: Double = 0.0
    
    @State private var sumaActivada = false
    var horizontalOrientation: Bool
    
    let layout3 = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    let layout4 = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible(minimum: 100))
    ]
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{

                
                if horizontalOrientation{
                    HStack{
                        Spacer()
                        Text("Total= \(String(format: "%.2f", sumaTotal))")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .bold()
                            .minimumScaleFactor(0.1)
                            .shadow(color: .gray, radius: 1, x: -2 , y: 2)
                        
                        Button(action:{
                            sumaTotal = 0
                        }){
                            Image(systemName: "gobackward")
                        }.padding(.trailing, 20)
                        
                        Button(action:{
                            sumaActivada.toggle()
                        }){
                            Text(sumaActivada ? "ADDING" : "ADD")
                                .font(.footnote)
                                .bold()
                                .padding()
                                .background(sumaActivada ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                
                                
                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.trailing, 10)
                    .shadow(color: .gray, radius: 3, x:2 , y: -2)
                    .shadow(color: .black, radius: 3, x:-2 , y: 2)
                    
                    
                    Divider()
                    
                    ScrollView{
                        LazyVGrid(columns: layout4, spacing: 5, content: {
                            ForEach(fetchRequest.wrappedValue, id: \.self){ servicio in
                                botonGrid(servicio: servicio, sumaTotal: $sumaTotal, sumaActivada: $sumaActivada, geometry: geometry)
                            }
                        })
                    }
                }
                else{
                    //en vertical
                    HStack{
                        Spacer()
                        Text("Total= \(String(format: "%.2f", sumaTotal))")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .shadow(color: .gray, radius: 1, x: -2 , y: 2)
                        
                        Button(action:{
                            sumaTotal = 0
                        }){
                            Image(systemName: "gobackward")
                        }.padding(.trailing, 20)
                        
                        Button(action:{
                            sumaActivada.toggle()
                        }){
                            Text(sumaActivada ? "ADDING" : "ADD")
                                .font(.footnote)
                                .bold()
                                .padding()
                                .background(sumaActivada ? Color.red : Color.blue)
                                .foregroundColor(.white)
                        }.clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .gray, radius: 3, x:2 , y: -2)
                    .shadow(color: .black, radius: 3, x:-2 , y: 2)
                    
                    Divider()
                    
                    ScrollView{
                        LazyVGrid(columns: layout3, spacing: 5, content: {
                            ForEach(fetchRequest.wrappedValue, id: \.self){ servicio in
                                botonGrid(servicio: servicio, sumaTotal: $sumaTotal, sumaActivada: $sumaActivada, geometry: geometry)
                            }
                        })
                    }
                }
                
            }
        }
        
    }
    
    init(filter: String, horizontal: Bool){
        
        if filter != "Todo"{
        fetchRequest = FetchRequest<Servicios>(entity: Servicios.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Servicios.nombreServicio, ascending: true)], predicate: NSPredicate(format: "categoriaAsociada.nombreCategoria MATCHES[dc] %@", filter),animation: .default)
            print(fetchRequest)
        }
        else{
            fetchRequest = FetchRequest<Servicios>(entity: Servicios.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Servicios.nombreServicio, ascending: true)],animation: .default)
        }
        
        if horizontal{
            self.horizontalOrientation = true
        }
        else{
            horizontalOrientation = false
        }
        
        
        
    }
}

struct botonGrid: View {
    @Environment(\.managedObjectContext) private var viewContext
    var servicio: Servicios
    @State private var showAlert = false
    @Binding var sumaTotal: Double
    @Binding var sumaActivada: Bool
    
    var geometry: GeometryProxy
    
    var body: some View{
        
        Button(action:{
            self.showAlert = true
        }){
            ZStack{
                if servicio.mostrarImgServicio{
                    //si no encuentra la imagen pone la imagen por defecto
                    if servicio.imgServicio == nil{
                        ImagenGridServicio(image: UIImage(imageLiteralResourceName: "iconoCasha"))
                    }
                    else{
                        ImagenGridServicio(image: leerImagen(data: servicio.imgServicio!))

                    }
               }
                else{
                    //si no se ha de mostrar la imagen pone una imagen de fondo blanco
                    ImagenGridServicio(image: UIImage(imageLiteralResourceName: "fondoBlanco"))
//
                }
                
                VStack{
                    Spacer()
                    Text(servicio.nombreServicio ?? "Sin nombre")
                        .frame(height: servicio.mostrarImgServicio ? geometry.size.width / 20 : geometry.size.width / 6)
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .bottom], 4)
                        .padding([.leading, .trailing] , 8)
                        .font(.custom("Arial-BoldItalicMT", size: 35))
                        .minimumScaleFactor(0.1)
                        .lineLimit(servicio.mostrarImgServicio ? 2 : 4)
                        .truncationMode(.head)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if !servicio.mostrarImgServicio{
                        Spacer()
                    }
                }
            }
             .padding(10)
        }.alert(isPresented: $showAlert, content: {
            Alert(
                title: Text("Register \(servicio.nombreServicio!)?"),
                  primaryButton: .default(Text("OK"), action: {
                    if sumaActivada{
                        sumaTotal += servicio.precioServicio
                    }else{
                        sumaTotal = servicio.precioServicio
                    }
                    
                    let registroNuevo = Registros(context: viewContext)
                    registroNuevo.regCategoria = servicio.categoriaAsociada?.nombreCategoria ?? "General"
                    registroNuevo.regFecha = Date()
                    registroNuevo.regPrecio = servicio.precioServicio
                    registroNuevo.regServicio = servicio.nombreServicio
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    
                    print("start purchase \(String(describing: servicio.nombreServicio))")
                  }),
                secondaryButton: .cancel(Text("Cancel")))
        })
    }
    
    private func leerImagen(data: Data)-> UIImage{
        var img = UIImage()
        let imgData = data
        let data = try! JSONDecoder().decode(Data.self, from: imgData)
        img = UIImage(data: data)!
        return img
    }
}

struct ImagenGridServicio: View {
    
    var image: UIImage
    var body: some View{
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black, radius: 3, x:2 , y: -2)
            .shadow(color: .gray, radius: 3, x:-2 , y: 2)
    }
}

struct CajaFiltrada_Previews: PreviewProvider {
    static var previews: some View {
        CajaFiltrada(filter: "General", horizontal: false)
    }
}

