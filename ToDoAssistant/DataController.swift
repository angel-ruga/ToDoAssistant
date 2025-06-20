//
//  DataController.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

@Observable @MainActor
class DataController {
    private let container: ModelContainer
    let modelContext: ModelContext
    
    var selectedFilter: Filter? = Filter.all
    
    init(inMemory: Bool = false) {
        let schema = Schema([ToDo.self, Tag.self])
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration("MyToDos", schema: schema, isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration("MyToDos", schema: schema, url: URL.documentsDirectory.appending(path: "MyToDos.store"))
        }
        do {
            self.container = try ModelContainer(for: ToDo.self, configurations: config)
            self.modelContext = container.mainContext
        } catch {
            fatalError("Could not configure the container")
        }
    }
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    func save() {
        if modelContext.hasChanges {
            try? modelContext.save()
        }
    }
    
    func delete<T: PersistentModel>(_ object: T) {
        modelContext.delete(object)
        save()
    }
    
    func deleteAll() {
        do {
            try modelContext.delete(model: ToDo.self)
        } catch {
            print("Error deleting all ToDo model objects: \(error.localizedDescription)")
        }
        
        do {
            try modelContext.delete(model: Tag.self)
        } catch {
            print("Error deleting all Tag model objects: \(error.localizedDescription)")
        }
        
        save()
    }
    
    func createSampleData() {
        //let modelContext = container.mainContext

        for i in 1...5 {
            //let tagID = UUID()
            let tagName = "Tag \(i)"
            let tag = Tag(name: tagName)

            for j in 1...10 {
                let toDoTitle = "ToDo \(i)-\(j)"
                let toDoContent = "Description goes here"
                let toDoDueDate = Date(timeInterval: Double.random(in: 1...100)*60*60*24, since: .now)
                let toDoCompleted = Bool.random()
                let toDoPriority = ToDo.Priority.allCases.randomElement()
                let toDo = ToDo(title: toDoTitle, content: toDoContent, priority: toDoPriority?.rawValue, completed: toDoCompleted, dueDate: toDoDueDate, tags: [tag])
                
                tag.toDos?.append(toDo)
                
                modelContext.insert(toDo)
            }
            
            modelContext.insert(tag)
        }

        try? modelContext.save()
    }
}
