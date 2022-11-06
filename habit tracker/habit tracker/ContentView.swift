//
//  ContentView.swift
//  habit tracker
//
//  Created by Ali Erdem Kökcik on 6.11.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
