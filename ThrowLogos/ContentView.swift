//
//  ContentView.swift
//  ThrowLogos
//
//  Created by Эдгар Назыров on 09.02.2022.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    
    var game = GameController()
    
    var body: some View {
        ARViewContainer(arView: game.makeARView())
            .edgesIgnoringSafeArea(.all)
            .gesture(game.drag)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
