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
    
    var selectedToDo: ToDo?
    
    private var saveTask: Task<Void, Error>?
    
    var filterText = ""
    
    init(inMemory: Bool = false) {
        
        // TODO: Check behavior of core data automaticallyMergesChangesFromParent and mergePolicy translated to SwiftData
        
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
                let toDoDueDate = Date(timeInterval: Double.random(in: -20...20)*60*60*24, since: .now)
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
    
    func missingTags(from toDo: ToDo) -> [Tag] {
        let request = FetchDescriptor<Tag>()
        let allTags = (try? modelContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(toDo.toDoTags)

        return difference.sorted()
    }
    
    func queueSave() {
        // Cancel the previous save task if it already was in progress
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            //This save will not be executed if the previous task threw an error
            save()
        }
    }
    
    // TODO: Add user-defined filtering and sorting
    func toDosForSelectedFilter() -> [ToDo] {
        let filter = selectedFilter ?? .all
        let filterDate = filter.maxDueDate
        
        // Predicates
        
        var enableMatchesTag: Bool
        let tagID: UUID // SwiftData predicates do not let us use another model (in this case, Tag), apparently.
        if let tag = filter.tag {
            enableMatchesTag = true
            tagID = tag.tagID
        } else {
            enableMatchesTag = false
            tagID = UUID()
        }
        let matchesTag = #Predicate<ToDo> { toDo in
            if let tags = toDo.tags {
                return tags.contains(where: {
                    if let toDoTagID = $0.id {
                        return toDoTagID == tagID
                    } else {
                        return false
                    }
                })
            } else {
                return false
            }
        }
        
        let hasMaxDueDate = #Predicate<ToDo> { toDo in
            if let dueDate = toDo.dueDate {
                return (dueDate <= filterDate)
            } else {
                return false
            }
        }
        
        let trimmedFilterText = self.filterText.trimmingCharacters(in: .whitespaces)
        let constantFilterText = self.filterText
        let matchesSearch = #Predicate<ToDo> { toDo in
            if trimmedFilterText.isEmpty == false {
                if let title = toDo.title {
                    if let content = toDo.content {
                        return title.localizedStandardContains(constantFilterText) || content.localizedStandardContains(constantFilterText)
                    } else {
                        return title.localizedStandardContains(constantFilterText)
                    }
                } else {
                    return false
                }
            } else {
                return true
            }
        }
        
        var allToDos: [ToDo]
        
        let descriptor = FetchDescriptor<ToDo>(
            predicate: #Predicate { toDo in
                hasMaxDueDate.evaluate(toDo)
                && matchesSearch.evaluate(toDo)
                && (enableMatchesTag ? matchesTag.evaluate(toDo) : true)
            }
        )
        allToDos = (try? modelContext.fetch(descriptor)) ?? []
        /*
        // Tag filtering here, because SwiftData cannot handle complex predicates yet.
        if let tag = filter.tag {
            allToDos = allToDos.filter { toDo in
                toDo.toDoTags.contains(where: { tag == $0 } )
            }
        }
         // In the end, it could handle it by not using another model (Tag), but its id property.
        */
        return allToDos.sorted()
    }
}
