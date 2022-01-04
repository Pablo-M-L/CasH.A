//
//  ListaCategorias.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//



import SwiftUI
import CoreData

struct ListaCategorias: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var mostrarAnyadirCategoria = false
    @State private var mostrarEditarCategoria = false
    @Binding var categoriaSeleccionada: String
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)],
        animation: .default)
    
    private var categorias: FetchedResults<Categorias>
    
    var categoria: Categorias?
    @State private var indiceCategoriaAborrar: IndexSet?
    @State private var mostrarAlertDelete = false
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    Image("fondo1")
                        .resizable()
                        //.scaledToFill()
                        .opacity(0.5)
                        .ignoresSafeArea()
                }
                
                //lista categorias
                VStack(alignment: .center){
                    
                    if !mostrarAnyadirCategoria{
                        HStack{
                            Text("Categories")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("rojoAppContraste"))
                                .shadow(color: Color.black, radius: 2)
                                .padding(.top, 25)
                            Spacer()
                        }

                        
                        List{
                            ForEach(categorias, id: \.self){ categoria in
                                celdaCategoria(mostrarEditarCategoria: mostrarEditarCategoria, categoriaSeleccionada: $categoriaSeleccionada, categoria: categoria, geometry: geometry)
                                    .alert(isPresented: $mostrarAlertDelete, content:{
                                        Alert(
                                            title: Text("CAUTION"),
                                            message: Text("All services linked to this category will be deleted."),
                                            primaryButton: .default(
                                                Text("OK"),
                                                action: {
                                                    for index in self.indiceCategoriaAborrar! {
                                                        let item = categorias[index]
                                                        viewContext.delete(item)
                                                        do {
                                                            try viewContext.save()
                                                        } catch let error {
                                                            print("Error: \(error)")
                                                        }
                                                    }
                                                    self.indiceCategoriaAborrar = nil
                                                }),
                                            secondaryButton: .cancel(Text("Cancel"))
                                        )
                                    })
                                    .cornerRadius(10)
                                
                            }
                            .onDelete(perform: deleteRow)
                            .padding(.bottom, 30)
                            
                        }
                        .padding(.bottom, 10)
                        .cornerRadius(10)
                        
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .shadow(color: Color.black, radius: 4)
                
                //añadir categoria
                VStack{
                    if mostrarAnyadirCategoria{
                        FormularioAnyadirCategoria(viewContext: viewContext, mostrarAnyadirCategoria: $mostrarAnyadirCategoria)
                            .padding(.leading, 5)
                            .padding(.trailing, 10)
                        
                        
                    }
                    else{
                        HStack{
                            Spacer()
                            Button(action:{
                                self.mostrarAnyadirCategoria = true
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
                .padding()
                .padding(.top, 10)
                
            }
            
        }
        
    }
    
    func deleteRow(at indexSet: IndexSet) {
        self.indiceCategoriaAborrar = indexSet
        self.mostrarAlertDelete = true
    }
}

struct celdaCategoria: View{
    @Environment(\.managedObjectContext) private var viewContext
    @State var mostrarEditarCategoria: Bool
    @State var mostrarDescripcion = false
    @Binding var categoriaSeleccionada: String
    var categoria: Categorias
    var geometry: GeometryProxy
    
    @State var categoryName = ""
    @State var categoryDescription = ""
    @State private var mostrarImagePicker = false
    @State private var imgCategoria = UIImage(imageLiteralResourceName: "iconoCasha")
    @State private var mostrarImgCategoria = false
    @State private var editarCelda = false
    @State private var mostrarTodo = false
    
    
    var body: some View{
        VStack{
            HStack{
                Spacer()
                //boton guardar
                Button(action: {
                    if editarCelda{
                        //si se está editando una categoria, al pulsar en save guarda los datos y cambia editar celda de estado.
                        guard self.categoria.nombreCategoria != "" else {return}
                        self.categoria.nombreCategoria = categoryName
                        self.categoria.descripcionCategoria = categoryDescription
                        self.categoria.mostrarImagen = mostrarImgCategoria
                        let imagenUIRedimensionada = resizeImage(image: imgCategoria)
                        let imageData =  imagenUIRedimensionada.jpegData(compressionQuality: 0.5)
                        let data = try! JSONEncoder().encode(imageData)
                        self.categoria.imagenCategoria = data
                        
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
                            .foregroundColor(Color("rojoAppContraste"))
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
                            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
                    }
                }
            }
            
            HStack{
                Text("Title:")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("rojoAppContraste"))
                    .shadow(color: .white, radius: 1, x: 0, y: 1)
                TextField("Title", text: $categoryName)
                    .font(.title3)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                
            }.disabled(editarCelda ? false : true)
            
            HStack{
                Button(action: {
                    mostrarTodo.toggle()
                }
                ){
                    IndicadorDesplegar(color: Color("rojoAppContraste"), mostrar: mostrarTodo)
                        .padding(.top, 5)
                        
                }
            }
            
            if mostrarTodo{
                VStack{
                    HStack{
                        Text("Image")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("rojoAppContraste"))
                            .shadow(color: .white, radius: 1, x: 0, y: 1)
                            .padding(.trailing, 10)
                        
                        Button(action:{
                            self.mostrarImgCategoria.toggle()
                        }){
                            Image(systemName: mostrarImgCategoria ? "eye.fill" : "eye.slash.fill")
                                .imageScale(.small)
                                .foregroundColor(Color("rojoAppContraste"))
                                .shadow(color: .white, radius: 1, x: 0, y: 1)
                        }
                        Spacer()
                    }
                    
                    HStack{
                        Button(action:{
                            self.mostrarImagePicker.toggle()
                        })
                        {
                            Image(uiImage: imgCategoria)
                                .resizable()
                                .scaledToFit()
                                .frame(height: geometry.size.height / 8)
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                                .shadow(color: .white, radius: 1, x: 0, y: 1)
                        }
                        .sheet(isPresented: $mostrarImagePicker){
                            ImagePicker(selectedImage: self.$imgCategoria)
                        }
                        Spacer()
                    }.padding(.trailing, 7)
                }
                .transition(.opacity)
                .animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 0.6))
                .disabled(editarCelda ? false : true)
                
                Divider()
                
                VStack{
                    HStack(alignment: .center){
                        Text("Description")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color("rojoAppContraste"))
                            .shadow(color: .white, radius: 1, x: 0, y: 1)
                        Button(action:{
                            mostrarDescripcion.toggle()
                        }){
                            IndicadorDesplegar(color: Color("rojoAppContraste"), mostrar: mostrarDescripcion)
                        }
                        Spacer()
                    }
                    
                    if mostrarDescripcion{
                        TextEditor(text: $categoryDescription)
                            .frame(height: 150)
                            .disabled(editarCelda ? false : true)
                    }
                }                .transition(.opacity)
                .animation(.spring(response: 0.8, dampingFraction: 1, blendDuration: 0.6))
                
            }
            
            
        }

        .padding()
        .background(Color("azulApp"))
        .buttonStyle(BorderlessButtonStyle())
        .onAppear{
            categoryName = categoria.nombreCategoria ?? "Empty"
            categoryDescription = categoria.descripcionCategoria ?? "Empty"
            mostrarImgCategoria = categoria.mostrarImagen
            if categoria.imagenCategoria == nil{
                imgCategoria = UIImage(imageLiteralResourceName: "iconoCasha")
            }
            else{
                let imgData = categoria.imagenCategoria
                let data = try! JSONDecoder().decode(Data.self, from: imgData!)
                imgCategoria = UIImage(data: data)!
            }
        }
        //.animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3))
        
    }
    
}

struct IndicadorDesplegar: View{
    var color: Color
    var mostrar: Bool
    var body: some View{

        Image(systemName: mostrar ? "chevron.up" : "chevron.down")
            .imageScale(.large)
            .foregroundColor(color)
            .shadow(color: .white, radius: 1, x: 0, y: 1)
        
    }
}

struct FormularioAnyadirCategoria: View{
    var viewContext: NSManagedObjectContext
    @Binding var mostrarAnyadirCategoria: Bool
    @State private var categoryName = ""
    @State private var categoryDescription = ""
    @State private var mostrarImagePicker = false
    @State private var imgCategoria = UIImage(imageLiteralResourceName: "iconoCasha")
    @State private var mostrarImgCategoria = true
    let device = UIDevice.current.userInterfaceIdiom
    
    
    var body: some View{
        GeometryReader{ geometry in
            VStack(){
                Form{
                    Section(header: Text("Title")){
                        TextField("Title", text: $categoryName)
                    }
                    Section(header: Text("Image")){
                        
                        HStack{
                            HStack{
                                Image(uiImage: imgCategoria)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height / 8)
                                    .clipShape(Circle())
                                    .padding(2)
                                    .onTapGesture{
                                        self.mostrarImagePicker.toggle()
                                    }
                                    .sheet(isPresented: $mostrarImagePicker){
                                        ImagePicker(selectedImage: self.$imgCategoria)
                                    }
                                Spacer()
                                Toggle(isOn: $mostrarImgCategoria){
                                    Text("")
                                }
                            }
                        }
                        
                    }
                    Section(header: Text("Description")){
                        TextEditor(text: $categoryDescription)
                            .padding(.bottom, 250)
                    }.onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                
                HStack{
                    Button(action: {
                        mostrarAnyadirCategoria = false
                    }){
                        Text("Cancel")
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        guardarCategoria()
                        mostrarAnyadirCategoria = false
                        
                    }){
                        Text("save")
                            .foregroundColor(.white)
                    }
                    
                }.padding()
                Spacer()
            }.onTapGesture {
                UIApplication.shared.endEditing()
                
            }
            
            .frame(width: geometry.size.width, height: geometry.size.height / 1.1)
            .background(Color.accentColor)
            .cornerRadius(15)
            .shadow(color: Color.black, radius: 3)
            
        }
        
    }
    
    private func guardarCategoria(){
        withAnimation {
            let categoria = Categorias(context: viewContext)
            categoria.id = UUID()
            categoria.nombreCategoria = categoryName
            categoria.descripcionCategoria = categoryDescription
            categoria.mostrarImagen = mostrarImgCategoria
            
            let imagenUIRedimensionada = resizeImage(image: imgCategoria)
            let imageData =  imagenUIRedimensionada.jpegData(compressionQuality: 0.5)
            let data = try! JSONEncoder().encode(imageData)
            categoria.imagenCategoria = data
            
            
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


struct ListaCategorias_Previews: PreviewProvider {
    static var previews: some View {
        ListaCategorias(categoriaSeleccionada: .constant("general"))
    }
}


