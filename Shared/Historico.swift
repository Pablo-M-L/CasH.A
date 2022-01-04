//
//  Historico.swift
//  CasH.A
//
//  Created by pablo on 8/3/21.
//


import SwiftUI
import CoreData

struct Historico: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Registros.regFecha, ascending: false)],
        animation: .default)
    private var registros: FetchedResults<Registros>
    @State private  var isSharePresented: Bool = false
    //@State private  var isFalse: Bool = false
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                HStack{
                    Image("fondo1")
                        .resizable()
                        .opacity(0.5)
                        .ignoresSafeArea()
                }


                    VStack(alignment: .center){
                        HStack{
                            Text("History")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("rojoAppContraste"))
                                .shadow(color: Color.black, radius: 4)
                                .padding(.leading, 20)
                                .padding(.trailing, 10)
                                .background(Color.white.opacity(0.7))

                            Spacer()

                            Button (action:{
                                self.isSharePresented.toggle()
                                // exportarDatos(registros: registros)
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                            .padding(.trailing, 35)
                            .shadow(color: Color.black, radius: 6)
                            .sheet(isPresented: $isSharePresented, onDismiss: {
                                print("dismiss ")
                            }, content:{
                                ActivityViewController(activityItems: [sharedFile(registros: registros)], applicationActivities: nil)
                            })
                        }
                        
                        List{
                            ForEach(registros, id: \.self){ registro in
                                VStack(alignment: .leading){
                                    FilaCelda(title: "Service:", dato: registro.regServicio!)
                                    Divider()
                                    FilaCelda(title: "Price:", dato: String(registro.regPrecio))
                                    Divider()
                                    FilaCelda(title: "WeekDay:", dato: getTodayWeekDay(date: registro.regFecha!))
                                    Divider()
                                    FilaCelda(title: "Day:", dato: obtenerFecha(date: registro.regFecha!))
                                    Divider()
                                    FilaCelda(title: "Time:", dato: obtenerHora(date: registro.regFecha!))
                                }
                                .padding(3)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(10)
                            }.onDelete{
                                IndexSet in
                                for index in IndexSet{
                                    viewContext.delete(registros[index])
                                }
                                do {
                                    try viewContext.save()
                                } catch {
                                    print(error.localizedDescription)
                                }

                            }
                            
                        }
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 15)
                        .shadow(color: Color.black, radius: 4)

                    }

            }

        }
        
    }
}

struct FilaCelda: View{
    var title: String
    var dato: String
    
    var body: some View{
        HStack{
            Text(title)
                .font(.caption2)
                .bold()
                .foregroundColor(Color("azulAppContraste"))
            Spacer()
            Text(dato)
                .font(.caption)
        }
    }
}

func obtenerFecha(date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter.string(from: date)
}

func obtenerHora(date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter.string(from: date)
}

func cambiarColorCelda(indice: Bool){
    
    
    
}


func getTodayWeekDay(date: Date)-> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    let weekDay = dateFormatter.string(from: date)
    return weekDay
}

private let itemFormatterDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

private let itemFormatterTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()



private func exportarDatos(registros: FetchedResults<Registros>)->String{
    var stringConCabecero = "service;category;price;date;time;weekDay\n"
    
    registros.forEach { (reg) in
        let title = reg.regServicio == "" ? "Empty" : reg.regServicio
        let category = reg.regCategoria == "" ? "Empty" : reg.regCategoria
        let price = reg.regPrecio == 0 ? 0 : reg.regPrecio
        
        let dateFormatter = DateFormatter()
        let horaFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        horaFormatter.dateFormat = "HH:mm:ss"//"dd/MM/yyyy - HH:mm:ss"
        let date: String = dateFormatter.string(from: reg.regFecha!)
        let time: String = horaFormatter.string(from: reg.regFecha!)
        let weekDay = getTodayWeekDay(date: reg.regFecha!)
        let stringAppend = "\(String(describing: title!));\(String(describing: category!));\(String(describing: price));\(String(describing: date)); \(String(describing: time));\(String(describing: weekDay))\n"
        stringConCabecero.append(stringAppend)
    }
    return stringConCabecero
}

func sharedFile(registros: FetchedResults<Registros>)-> URL{
    print("sha")
    let nombreFile = "Registro.csv"
    let csv = exportarDatos(registros: registros) //stringConCabecero
    let fileManager = FileManager.default
    
    
    do {
        
        let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil , create: false )
        
        let fileURL = path.appendingPathComponent(nombreFile)
        
        try csv.write(to: fileURL, atomically: true , encoding: .utf8)
        
        return fileURL
        //let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Pedidos.csv")
        //            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        //            activityVC.popoverPresentationController?.sourceRect = sender.frame
        //            activityVC.popoverPresentationController?.sourceView = self.view
        //            present(activityVC,animated: true)
    }
    catch {
        print("error creating file")
    }
    
    return URL(string: "https://www.apple.com")!
    
}

//struct Historico_Previews: PreviewProvider {
//    static var previews: some View {
//        Historico()
//    }
//}

