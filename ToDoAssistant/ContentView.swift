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
    
    // TODO: Add user-defined filtering and sorting
    
    var toDos: [ToDo] {
        let filter = dataController.selectedFilter ?? .all
        let filterDate = filter.maxDueDate
        var allToDos: [ToDo]
        
        if let tag = filter.tag {
            allToDos = tag.toDos ?? []
        } else {
            let descriptor = FetchDescriptor<ToDo>(
                predicate: #Predicate {
                    if let dueDate = $0.dueDate {
                        return dueDate < filterDate
                    } else {
                        return false
                    }
                }
            )
            allToDos = (try? dataController.modelContext.fetch(descriptor)) ?? []
        }

        return allToDos.sorted()
    }
    
    var body: some View {
        List {
            ForEach(toDos) { toDo in
                ToDoRow(toDo: toDo)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("ToDos")
        //.toolbarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = toDos[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
