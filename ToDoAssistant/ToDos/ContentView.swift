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

    var body: some View {
        @Bindable var dataController = dataController

        List(selection: $dataController.selectedToDo) {
            ForEach(dataController.toDosForSelectedFilter()) { toDo in
                ToDoRow(toDo: toDo)
            }
            .onDelete(perform: delete)
        }
        .searchable(text: $dataController.filterText, prompt: "Filter ToDos")
        .toolbar(content: ContentViewToolbar.init)
        .navigationTitle("ToDos")
        .navigationBarTitleDisplayMode(.inline)
    }

    func delete(_ offsets: IndexSet) {
        let toDos = dataController.toDosForSelectedFilter()

        for offset in offsets {
            let item = toDos[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
