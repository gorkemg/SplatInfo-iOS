//
//  ContentView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
