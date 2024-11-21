//
//  ContentView.swift
//  Encrypted Camera
//
//  Created by Robby Carff on 11/21/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))  // Adjust the size
                .foregroundColor(.blue)  // Adjust the color
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
