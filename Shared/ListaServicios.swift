//
//  ListaServicios.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//

import SwiftUI
import CloudKit
import CoreData

struct ListaServicios: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)],
        animation: .default)
    
    private var categorias: FetchedResults<Categorias>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Servicios.nombreServicio, ascending: true)],
        animation: .default)
    
    private var servicios: FetchedResults<Servicios>
    @State var objectoCategoriaSeleccionada: Categorias? = nil
    @State private var mostrarAnyadirServicio = false
    @State private var mostrarEditarServicio = false
    @State private var categoriaSeleccionada = "general"
    var lista = ["Teams list Empty","sin lista"]
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                
                VStack{
                    Image("fondo1")
                        .resizable()
                        .opacity(0.5)
                        .ignoresSafeArea()
                }
                
                VStack(alignment: .center){
                    if !mostrarAnyadirServicio{
                        HStack{
                            Text("Services")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("rojoAppContraste"))
                                .shadow(color: Color.black, radius: 2)
                                .padding(.top, 25)
                            Spacer()
                        }
                        List{
                            ForEach(servicios, id: \.self){ servicio in
                                celdaServicios(listaCategorias: leerCategorias(listaCategorias: categorias), viewContext: viewContext ,servicio: servicio, geometry: geometry)
                                    .cornerRadius(10)
                            }.onDelete{
                                IndexSet in
                                for index in IndexSet{
                                    viewContext.delete(servicios[index])
                                }
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                            }
                            .padding(.bottom, 30)
                            
                        }
                        .padding(.bottom, 10)
                        .cornerRadius(10)
                        
                    }
                }.padding(.leading, 8)
                .padding(.trailing, 18)
                .shadow(color: Color.black, radius: 4)
                
                VStack{
                    if mostrarAnyadirServicio{
                        anyadirServicio(viewContext: viewContext, mostrarAnyadirServicio: $mostrarAnyadirServicio)
                            .padding(.leading, 5)
                            .padding(.trailing, 10)
                    }
                    else{
                        HStack{
                            Spacer()
                            Button(action:{
                                self.mostrarAnyadirServicio = true
                            }){
                                Image(systemName: "plus")
                                    .renderingMode(.original)
                            }
                            .padding(20)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black, radius: 6)
                            
                        }
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
            }
            
        }
    }
    
    private func leerCategorias(listaCategorias: FetchedResults<Categorias>) -> [String]{
        
        var arrayCategorias: [String]{
            
            var array = ["General"]
            for categoria in listaCategorias{
                array.append(categoria.nombreCategoria ?? "Empty")
            }
            return array
        }
        
        return arrayCategorias
    }
    

}

struct celdaServicios: View{
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)],
        animation: .default)
    
    private var categorias: FetchedResults<Categorias>
    
    var listaCategorias: [String]
    //var categorias: FetchedResults<Categorias>
    var viewContext: NSManagedObjectContext
    var servicio: Servicios
    @State var mostrarEditarServicio = false
    var geometry: GeometryProxy
    
    @State var mostrarDescripcion = false
    
    @State private var mostrarCategorias = false
    @State private var nombreServicio: String = "sin nombre servicio"
    @State private var descripcionServicio: String = "sin descripcion"
    @State private var categoriaServico: String = "General"
    @State private var categoriaSeleccionada = "General"
    @State private var seleccionandoCategoria = false
    @State private var precioServicio = "0.0"
    @State private var mostrarImagePicker = false
    @State private var imgServicio = UIImage(imageLiteralResourceName: "iconoCasha")
    @State private var mostrarImgServicio = true
    @State private var editarCelda = false
    @State private var mostrarTodo = false
    
    @State var objectoCategoriaSeleccionada: Categorias? = nil
    
    var body: some View{
        VStack{
            //boton guardar
            HStack{
                Spacer()
                Button(action: {
                    if editarCelda{
                        guard self.servicio.nombreServicio != "" else {return}
                        self.servicio.categoriaAsociada = objectoCategoriaSeleccionada
                        self.servicio.nombreServicio = nombreServicio
                        self.servicio.descripcionServicio = descripcionServicio
                        self.servicio.categoria = objectoCategoriaSeleccionada?.nombreCategoria
                        self.servicio.precioServicio = Double(precioServicio) ?? 0.0
                        self.servicio.mostrarImgServicio = mostrarImgServicio
                        let imagenUIRedimensionada = resizeImage(image: imgServicio)
                        let imageData =  imagenUIRedimensionada.jpegData(compressionQuality: 0.5)
                        let data = try! JSONEncoder().encode(imageData)
                        self.servicio.imgServicio = data
                        

                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                        editarCelda = false
                    }else{
                        editarCelda = true
                    }
                    
            
                }){
                    if editarCelda{
                        Text("Save")
                            .font(.title3)
                            .foregroundColor(Color("azulAppContraste"))
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    }else{
                        Image(systemName:  "pencil")
                            .imageScale(.small)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 2, x: 1, y: 1)
                    }
                }
            }

            
            HStack{
                Text("Title: ")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("azulAppContraste"))
                    .shadow(color: .white, radius: 1, x: 0, y: 1)
                TextField("Title", text: $nombreServicio)
                    .font(.title3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
            .disabled(editarCelda ? false : true)
            
            HStack{
                Button(action: {
                    self.mostrarTodo.toggle()
                }){
                    IndicadorDesplegar(color: Color("azulAppContraste"), mostrar: mostrarTodo)
                        .padding(.top, 5)
                }
            }
            
            if mostrarTodo{
                HStack(alignment: .center){
                    Text("Category:")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("azulAppContraste"))
                        .shadow(color: .white, radius: 1, x: 0, y: 1)
                    Text(" \(categoriaSeleccionada)")
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .onTapGesture {
                            mostrarCategorias.toggle()
                        }
                    Spacer()
                }
                .disabled(editarCelda ? false : true)
                .padding(.bottom, 5)
                
                if mostrarCategorias{
                    VStack(alignment: .center){
                        Text("Select Category")
                            .font(.title)
                            .foregroundColor(Color("azulAppContraste"))
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                            .shadow(color: .white, radius: 1, x: 0, y: 1)
                            
                        Divider()
                        ForEach(categorias, id: \.self){ catg in
                            HStack{
                                Spacer()
                                Text("\(catg.nombreCategoria ?? "nada")")
                                    .onTapGesture {
                                        
                                        objectoCategoriaSeleccionada = catg
                                        categoriaSeleccionada = objectoCategoriaSeleccionada?.nombreCategoria ?? "N category"
                                        mostrarCategorias = false
                                    }
                                Spacer()
                            }.padding(.bottom, 10)
                        }
                    }.background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                }
                
                Divider()
                
                VStack{
                    HStack{
                        Text("Image:")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("azulAppContraste"))
                            .shadow(color: .white, radius: 1, x: 0, y: 1)
                            .padding(.trailing, 10)
                        Button(action:{
                            self.mostrarImgServicio.toggle()
                        }){
                            Image(systemName: mostrarImgServicio ? "eye.fill" : "eye.slash.fill")
                                .imageScale(.medium)
                                .shadow(color: .white, radius: 1, x: 0, y: 1)
                        }
                        Spacer()
                    }
                    HStack{
                        //boton cambiar imagen y toggle
                        HStack{
                            Button(action:{
                                self.mostrarImagePicker.toggle()
                            })
                            {
                                Image(uiImage: imgServicio)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height / 8)
                                    .clipShape(Circle())
                                    .padding(.trailing, 8)
                                    .shadow(color: .white, radius: 1, x: 0, y: 1)
                            }
                            .sheet(isPresented: $mostrarImagePicker){
                                ImagePicker(selectedImage: self.$imgServicio)
                            }
                            Spacer()
                        }.padding(.trailing, 7)
                
                    }
                }
                .disabled(editarCelda ? false : true)
                
                Divider()
                
                HStack{
                    Text("Price:")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("azulAppContraste"))
                        .shadow(color: .white, radius: 1, x: 0, y: 1)
                    Spacer()
                    TextField("Price", text: $precioServicio)
                        .font(.title3)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
                .padding(.trailing, 7)
                .disabled(editarCelda ? false : true)
                
                VStack{
                    HStack(alignment: .center){
                        Text("Description")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("azulAppContraste"))
                            .shadow(color: .white, radius: 1, x: 0, y: 1)
                        Button(action:{
                            mostrarDescripcion.toggle()
                        }){
                            IndicadorDesplegar(color: Color("azulAppContraste"), mostrar: mostrarDescripcion)
                        }
                        Spacer()
                    }
                    
                    if mostrarDescripcion{
                        TextEditor(text: $descripcionServicio)
                            .frame(height: 150)
                            .disabled(editarCelda ? false : true)
                    }
                }.animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 0.6))
            }




        }

        .padding()
        .background(Color("rojoApp"))
        .onAppear{
                objectoCategoriaSeleccionada = servicio.categoriaAsociada
                nombreServicio = servicio.nombreServicio ?? "sin nombre"
                descripcionServicio = servicio.descripcionServicio ?? "sin description"
                categoriaSeleccionada = servicio.categoriaAsociada?.nombreCategoria ?? "no Category"
                precioServicio = String(servicio.precioServicio)
                mostrarImgServicio = servicio.mostrarImgServicio
                seleccionandoCategoria = true
                if servicio.imgServicio == nil{
                    imgServicio = UIImage(imageLiteralResourceName: "iconoCasha")
                }
                else{
                    let imgData = servicio.imgServicio
                    let data = try! JSONDecoder().decode(Data.self, from: imgData!)
                    imgServicio = UIImage(data: data)!
                }
        }
        .buttonStyle(BorderlessButtonStyle())
        .animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 0.6))
    }
    

}


struct anyadirServicio: View{
    var viewContext: NSManagedObjectContext

    //var listaCategorias: [String]
    //var lista = ["Teams list Empty","sin lista"]
    //@State var categoriaSel: Categorias? = nil
    
    @Binding var mostrarAnyadirServicio: Bool
    @State private var nombreServicio = ""
    @State private var descripcionServicio = "Description"
    @State private var mostrarListadoCategorias = false
    @State private var categoriaSeleccionada = "No Category"
    @State private var precioServicio = "0.0"
    @State private var mostrarCategorias = false
    @State private var mostrarImagePicker = false
    @State private var imgServicio = UIImage(imageLiteralResourceName: "iconoCasha")
    @State private var mostrarImgServicio = true
    
    @State var objectoCategoriaSeleccionada: Categorias? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)],
        animation: .default)
    
    private var categorias: FetchedResults<Categorias>
    
    //obtener categoria general por si al crear el servicio no le asigna categoria
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)], predicate: NSPredicate(format: "nombreCategoria MATCHES[dc] %@","General"),
        animation: .default)
    private var categoriGeneral: FetchedResults<Categorias>
    
  
    var body: some View{
        GeometryReader{ geomerty in
            VStack(alignment: .center){
                
                if mostrarCategorias{

                    VStack(alignment: .center){
                        Text("Select Category")
                            .font(.title)
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                        
                        Divider()
                        List{
                            ForEach(categorias, id:\.self){categ in
                                HStack(alignment: .center){
                                    Spacer()
                                    Text("\(categ.nombreCategoria ?? "nda")")
                                        .onTapGesture {
                                            objectoCategoriaSeleccionada = categ
                                            categoriaSeleccionada = objectoCategoriaSeleccionada?.nombreCategoria ?? "No Category"
                                            mostrarCategorias = false
                                        }
                                    Spacer()
                                }

                            }
                        }.padding(.top, 15)
                        
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                    

                    
                }

                Form{
                    Section(header: Text("Category")) {
                        Text("Category: \(categoriaSeleccionada)")
                            .onTapGesture {
                                mostrarCategorias.toggle()
                            }
                    }
                    Section(header: Text("Title")){
                        TextField("Service Title", text: $nombreServicio)
                    }
                    
                    Section(header: Text("Price")){
                        TextField("insert service price", text: $precioServicio)
                    }
                    Section(header: Text("Image")){
                        HStack{
                            Button(action:{
                                self.mostrarImagePicker.toggle()
                            })
                            {
                                Image(uiImage: imgServicio)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geomerty.size.height / 8)
                                    .clipShape(Circle())
                                    .padding(2)
                            }
                            .sheet(isPresented: $mostrarImagePicker){
                                ImagePicker(selectedImage: self.$imgServicio)
                            }
                            Spacer()
                            Toggle(isOn: $mostrarImgServicio){
                                Text("")
                            }
                        }
                    }
                    
                    Section(header: Text("Description")) {
                        TextEditor(text: $descripcionServicio)
                            .padding(.bottom, 250)
                    }.onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                
                HStack{
                    Button(action: {
                        mostrarAnyadirServicio = false
                    }){
                        Text("Cancel")
                            .foregroundColor(.white)
                            
                    }
                    
                    Spacer()
                    
                    Button(action: {
                    if categoriaSeleccionada != "No Category"{
                        guardarServicio()
                        mostrarAnyadirServicio = false
                    }
                    else{
                        //si no ha seleccionado ninguna categoria se le asigna la categoria general.
                        if categoriGeneral.count > 0{
                            //comprobamos que si ha encontrado una categoria general.
                            objectoCategoriaSeleccionada = categoriGeneral[0]
                               guardarServicio()
                               mostrarAnyadirServicio = false
                        }
                        else{
                            //si no encuentra la categoria general la crea.
                            crearCategoriaGeneral(viewcontext: viewContext)
                            objectoCategoriaSeleccionada = categoriGeneral[0]
                            guardarServicio()
                            mostrarAnyadirServicio = false
                        }

                    }
                        
                    }){
                        Text("Save")
                            .foregroundColor(.white)

                    }
                    
                }.padding(20)
                
            }.frame(width: geomerty.size.width, height: geomerty.size.height / 1.05)
            .background(Color.accentColor)
            .cornerRadius(15)
            .shadow(color: Color.black, radius: 3)
            
            
        }
    }
    
    private func guardarServicio(){
            withAnimation {
                let servicio = Servicios(context: viewContext)
                servicio.id = UUID()
                servicio.nombreServicio = nombreServicio
                servicio.descripcionServicio = descripcionServicio
                servicio.categoria = objectoCategoriaSeleccionada?.nombreCategoria
                servicio.precioServicio = Double(precioServicio) ?? 0.0
                servicio.mostrarImgServicio = mostrarImgServicio
                let imagenUIRedimensionada = resizeImage(image: imgServicio)
                let imageData =  imagenUIRedimensionada.jpegData(compressionQuality: 0.5)
                let data = try! JSONEncoder().encode(imageData)
                servicio.imgServicio = data
                servicio.categoriaAsociada = objectoCategoriaSeleccionada

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }

        
    }
}

struct ListaServicios_Previews: PreviewProvider {
    static var previews: some View {
        ListaServicios()
    }
}
