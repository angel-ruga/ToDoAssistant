//
//  ContentView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 15/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(DataController.self) private var dataController
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Text("Content")
    }
}

#Preview {
    ContentView()
}
