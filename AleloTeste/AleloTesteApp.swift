//
//  AleloTesteApp.swift
//  AleloTeste
//
//  Created by Erick Sens on 06/06/23.
//

import SwiftUI

let cartManager = CartManager()


@main
struct AleloTesteApp: App {
   
    var body: some Scene {
        WindowGroup {
                   ContentView()
                       .environmentObject(cartManager)
               }
    }
}
