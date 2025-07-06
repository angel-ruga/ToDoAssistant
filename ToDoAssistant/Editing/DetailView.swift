//
//  DetailView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 18/06/25.
//

import SwiftUI

struct DetailView: View {
    @Environment(DataController.self) private var dataController

    var body: some View {
        VStack {
            if let toDo = dataController.selectedToDo {
                ToDoView(toDo: toDo)
            } else {
                NoToDoView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}
