//
//  Helper.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//

import Foundation
import SwiftUI
import CoreData

class Helper: ObservableObject{
    
    @Published var isFalse: Bool = true
    
    func cambiar()-> Bool{
        isFalse.toggle()
        return isFalse
    }
}

func estaEnHorizontal(geometry: GeometryProxy)-> Bool{
    if geometry.size.width > geometry.size.height{
        return true
    }
    else{
        return false
    }
}

func comprobarEspacios(str: String)-> Bool{
    // para saber si la categoria tiene mas de una palabra, y asi limitar la lineas a 1 o no, y evitar que divida una palabra cuando esta sola.
    let whitespace = NSCharacterSet.whitespaces
    let conEspacios = str.rangeOfCharacter(from: whitespace) != nil
    if conEspacios{
        return true
    }
    else {
        return false
    }
}

func resizeImage(image: UIImage)->UIImage{
    // le doy el mismo valor a width que a height para que el resultado sea una imagen cuadrada.
    let originalSize = image.size
    //obtener factor de escalado
    let witdhRatio = 250 / originalSize.width
    let heightRatio = 250 / originalSize.width
    //let heightRatio = 250 / originalSize.height
    
    let targerRatio = max(witdhRatio, heightRatio)
    let newSize = CGSize(width: originalSize.width * targerRatio, height: originalSize.width * targerRatio)
    
    //definir el rectangulo. (la zona donde se va a renderizar)
    let rectImagen = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rectImagen)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //destapar nuevaImagen que es UIImage?
    guard let nuevaImagen = newImage else {
        return image
    }
    return nuevaImagen
    
}

func crearCategoriaGeneral(viewcontext: NSManagedObjectContext){
    let viewContext = viewcontext
    
    let imgCategoria = UIImage(imageLiteralResourceName: "iconoCasha")
    let categoria = Categorias(context: viewContext)
    categoria.id = UUID()
    categoria.nombreCategoria = "General"
    categoria.descripcionCategoria = "General Services"
    categoria.mostrarImagen = true
    let imagenUIRedimensionada = resizeImage(image: imgCategoria)
    let imageData =  imagenUIRedimensionada.jpegData(compressionQuality: 0.5)
    let data = try! JSONEncoder().encode(imageData)
    categoria.imagenCategoria = data
    

    do {
        try viewContext.save()
    } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
}

//para ocultar teclado
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//UIActivitiViewController para compartir archivo

struct ActivityViewController: UIViewControllerRepresentable{
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
