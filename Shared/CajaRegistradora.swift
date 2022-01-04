//
//  CajaRegistradora.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//


import SwiftUI

struct CajaRegistradora: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var horizontal = UIDeviceOrientation.RawValue.self
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Servicios.nombreServicio, ascending: true)],
        animation: .default)
    private var servicios: FetchedResults<Servicios>
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorias.nombreCategoria, ascending: true)],
        animation: .default)
    
    private var categorias: FetchedResults<Categorias>
    
    
    @State var categoriaSeleccionada = "Todo" //guarda la categoria seleccionada para filtrar los servicios y aumentar su tamaño
    
    
    let layout = [
        GridItem(.flexible(maximum: 350))
    ]
    
    var rows: [GridItem] = Array(repeating: .init(.flexible()), count: 1) //define el numero de filas
    
    var body: some View {
        
        GeometryReader{ geometry in
            //si esta en horizontal pone el scroll con las categorias en vertical y a la derecha.
            if estaEnHorizontal(geometry: geometry){
                ZStack{
                    Image("fondo1")
                        .resizable()
                        .opacity(0.5)
                    HStack{
                        ScrollView(.vertical){
                            LazyVGrid(columns: layout, alignment: .center, spacing: 10) {
                                ForEach(crearListaCategorias(), id: \.self){ item in
                                    
                                    //el primer item de la lista es Todo, que se le pasa el icono casha y muestra todos los servicios.
                                    if item == "Todo"{
                                        botonCategoria(categoriaSeleccionada: $categoriaSeleccionada, item: item, geometry: geometry, image: UIImage(imageLiteralResourceName: "iconoCasha"), mostrarImagen: true)
                                    }
                                    else{
                                        if comprobarCategoriaExiste(nombreCategoria: item){
                                            let categoria = obtenerCategoria(nombreCategoria: item)
                                            
                                            botonCategoria(categoriaSeleccionada: $categoriaSeleccionada, item: item, geometry: geometry, image: obtenerImgCategoria( categoria: categoria), mostrarImagen: categoria.mostrarImagen)
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                        .frame(width: geometry.size.width / 7)
                        
                        CajaFiltrada(filter: categoriaSeleccionada, horizontal: estaEnHorizontal(geometry: geometry))
                        
                    }
                    .padding(.top, 20)
                }.edgesIgnoringSafeArea(.top)
            }else{
                //en vertical, pone el scroll de categorias arriba
                ZStack{
                    Image("fondo1")
                        .resizable()
                        .opacity(0.5)
                    VStack(alignment: .leading){
                        ScrollView(.horizontal){
                            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                                ForEach(crearListaCategorias(), id: \.self){ item in
                                    
                                    //el primer item de la lista es Todo, que se le pasa el icono casha y muestra todos los servicios.
                                    if item == "Todo"{
                                        let imagen = resizeImage(image: UIImage(imageLiteralResourceName: "iconoCasha"))
                                        botonCategoria(categoriaSeleccionada: $categoriaSeleccionada, item: item, geometry: geometry, image: imagen, mostrarImagen: true)
                                    }
                                    else{
                                        if comprobarCategoriaExiste(nombreCategoria: item){
                                            let categoria = obtenerCategoria(nombreCategoria: item)
                                            
                                            botonCategoria(categoriaSeleccionada: $categoriaSeleccionada, item: item, geometry: geometry, image: obtenerImgCategoria( categoria: categoria), mostrarImagen: categoria.mostrarImagen)
                                        }
                                    }
                                    
                                    
                                }
                            }
                        }
                        .padding(.top, 25)
                        .padding(.leading, 10)
                        .frame(height: geometry.size.height / 4.2)
                        
                        Divider()
                        
                        CajaFiltrada(filter: categoriaSeleccionada, horizontal: estaEnHorizontal(geometry: geometry))
                            .padding([.leading,.trailing], 15)
                            .padding(.bottom, 30)
                        
                    }
                }.edgesIgnoringSafeArea(.top)
            }
        }
        
        
        
    }
    
    
    
    func comprobarCategoriaExiste(nombreCategoria: String)-> Bool{
        //comprueba que la categoria asociada al servicio existe. aunque en principio no se puede dar esta situacion ya que cuando se borra una categoria se borra los servicios asociados.
        var existe = false
        self.categorias.forEach { (cat) in
            if nombreCategoria == cat.nombreCategoria{
                existe = true
            }
        }
        return existe
    }
    
    func obtenerImgCategoria(categoria: Categorias)->UIImage{
        //devuelve la imagen guardada de la categoria y si no la obtiene devuelve la imagen del icono.
        var imagen = UIImage(imageLiteralResourceName: "iconoCasha")
        if categoria.imagenCategoria != nil{
            let data = try! JSONDecoder().decode(Data.self, from: categoria.imagenCategoria!)
            imagen = UIImage(data: data)!
        }
        return imagen
    }
    
    private func obtenerCategoria(nombreCategoria: String)->Categorias{
        //obtiene el objeto de cada categoria a partir del nombre de la categoria (String).
        //a partir del objeto categoria obtenido se le pasa los datos de este (mostar texto, imagen...) al boton categoria.
        var categoria: Categorias = Categorias()
        self.categorias.forEach { (cat) in
            if nombreCategoria == cat.nombreCategoria{
                categoria = cat
            }
        }
        return categoria
    }
    
    private func crearListaCategorias()->[String]{
        //crea un string con la lista de categorias añadiendo la primera "todo" que es para mostrar todos los servicios.
        var arrayCategorias: [String] = ["Todo"]
        categorias.forEach { (catg) in
            let categoria = catg.nombreCategoria ?? "Todo"
            
            if !arrayCategorias.contains(categoria){
                arrayCategorias.append(categoria)
            }
        }
        return arrayCategorias
    }
}

struct botonCategoria: View{
    
    @Binding var categoriaSeleccionada: String
    var item: String
    var geometry: GeometryProxy
    var image: UIImage
    var mostrarImagen: Bool
    
    var body: some View{
        if estaEnHorizontal(geometry: geometry){
            structBotonCategoria(title: item, image: image, mostrarImagen: mostrarImagen, categoriaSeleccionada: $categoriaSeleccionada)
                .frame(width: categoriaSeleccionada == item ? geometry.size.width / 8 : geometry.size.width / 13)
                .padding([.leading, .trailing], 5)
        }
        else{
            structBotonCategoria(title: item, image: image, mostrarImagen: mostrarImagen, categoriaSeleccionada: $categoriaSeleccionada)
                .frame(width: categoriaSeleccionada == item ? geometry.size.width / 4 : geometry.size.width / 6)
        }
    }
}

struct structBotonCategoria: View {
    var title: String
    var image: UIImage
    var mostrarImagen: Bool
    @Binding var categoriaSeleccionada: String
    
    var body: some View{
        Button(action:{
            categoriaSeleccionada = title
        }){
            VStack{
                if mostrarImagen{
                    imagenCategoria(image: image)
                }
                else{
                    ZStack{
                        imagenFondoTextoCategoria()
                        
                        textoCategoria(title: title, mostrarImagen: mostrarImagen)
                        
                    }
                    
                }
            }
            
        }
    }
}

struct imagenCategoria: View {
    var image: UIImage
    
    var body: some View{
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
            .shadow(color: Color.black, radius: 3, x: 2, y: 2)
    }
}

struct imagenFondoTextoCategoria: View {
    
    var body: some View{
        Image(uiImage: UIImage(imageLiteralResourceName: "fondoBlanco"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black, radius: 3, x: 2, y: 2)
            .shadow(color: Color.gray, radius: 3, x: -2, y: -2)
    }
}

struct textoCategoria: View {
    
    var title: String
    var mostrarImagen: Bool
    
    var body: some View{
        Text(title)
            .font(.custom("Verdana", size: mostrarImagen ? 12 : 24))
            .fontWeight(.bold)
            .minimumScaleFactor(0.2)
            .padding(5)
            .lineLimit(comprobarEspacios(str: title) ? 2 : 1)
            .foregroundColor(.black)
            .clipShape(Rectangle())
            .shadow(color: Color.gray, radius: 1, x: 1, y: 1)
    }
}

struct CajaRegistradora_Previews: PreviewProvider {
    static var previews: some View {
        CajaRegistradora()
    }
}

