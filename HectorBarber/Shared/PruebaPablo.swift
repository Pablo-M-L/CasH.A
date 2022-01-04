//
//  PruebaPablo.swift
//  HectorBarber
//
//  Created by pablo on 9/3/21.
//

import SwiftUI

struct PruebaPablo: View {
    
    @State var cambia = false
    var body: some View {
        
        VStack{
            Button(action:{
                cambia.toggle()
            }){
                Text("pulsa")
                    .padding()
                    .background(Color.red.opacity(0.5))
            }
            
            if cambia{
                Text("soy pablo")
                    .bold()
                    .padding()
                    .background(Color.purple)
                    .padding()
                    .background(Color.orange)
                    .font(.custom("Arial", size:90))
            }
        }

            
            
        
    }
}

struct PruebaPablo_Previews: PreviewProvider {
    static var previews: some View {
        PruebaPablo()
    }
}
