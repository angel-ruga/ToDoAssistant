//
//  DataController.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

enum SortType: String {
    case dueDate
    case alphabetical
}

enum Status: String {
    case all = "All"
    case done = "Done"
    case notDone = "Not Done"
}

@Observable @MainActor
class DataController {
    
    private let container: ModelContainer
    let modelContext: ModelContext
    
    var selectedFilter: Filter? = Filter.all
    
    var selectedToDo: ToDo?
    
    private var saveTask: Task<Void, Error>?
    
    // Filtering
    var filterText = ""
    var filterEnabled = false
    var filterPriority = -1
    var filterStatus = Status.all
    var sortType = SortType.alphabetical
    var sortDueSoonFirst = true
    var sortAZ = true
    
    init(inMemory: Bool = false) {
        
        // TODO: Check behavior of CoreData automaticallyMergesChangesFromParent and mergePolicy translated to SwiftData
        
        let schema = Schema([ToDo.self, Tag.self])
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration("MyToDos", schema: schema, isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration("MyToDos", schema: schema, url: URL.documentsDirectory.appending(path: "MyToDos.store")) // swiftlint:disable:this line_length
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
        saveTask?.cancel() // Just in case this method was called in .onSubmit(dataController.save)
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
        // let modelContext = container.mainContext

        for tagCounter in 1...5 {
            // let tagID = UUID()
            let tagName = "Tag \(tagCounter)"
            let tag = Tag(name: tagName)

            for toDoCounter in 1...10 {
                let toDoTitle = "ToDo \(tagCounter)-\(toDoCounter)"
                let toDoContent = "Description goes here"
                let toDoDueDate = Date(timeInterval: Double.random(in: -20...20)*60*60*24, since: .now)
                let toDoCompleted = Bool.random()
                let toDoPriority = ToDo.Priority.allCases.randomElement()
                let toDo = ToDo(title: toDoTitle, content: toDoContent, priority: toDoPriority?.rawValue, completed: toDoCompleted, dueDate: toDoDueDate, tags: [tag]) // swiftlint:disable:this line_length
                
                tag.toDos?.append(toDo)
                
                modelContext.insert(toDo)
            }
            
            modelContext.insert(tag)
        }

        try? modelContext.save()
    }
    
    // Get all the existing tags not on the provided ToDo
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
            // This save will not be executed if the previous task threw an error
            save()
        }
    }
    
    func sortDescriptorForSelectedFilter() -> [SortDescriptor<ToDo>] {
        let azSort = SortDescriptor<ToDo>(
            \ToDo.title,
             order: self.sortAZ ? .forward : .reverse
        )
        
        let dueSoonSort = SortDescriptor<ToDo>(
            \ToDo.dueDate,
             order: self.sortDueSoonFirst ? .forward : .reverse
        )
        
        let finalSort: [SortDescriptor<ToDo>]
        
        switch self.sortType {
        case SortType.alphabetical:
            finalSort = [azSort, dueSoonSort]
        case SortType.dueDate:
            finalSort = [dueSoonSort, azSort]
        }
        
        return finalSort
    }
    
    func toDosForSelectedFilter() -> [ToDo] {
        let finalPredicate = predicateForSelectedFilter()
        let finalSortDescriptor = sortDescriptorForSelectedFilter()
        let descriptor = FetchDescriptor<ToDo>(
            predicate: finalPredicate,
            sortBy: finalSortDescriptor
        )
        
        var allToDos: [ToDo]
        allToDos = (try? modelContext.fetch(descriptor)) ?? []
        
        return allToDos
    }
    
    func newToDo() {
        let toDo = ToDo()
        toDo.toDoTitle = "New ToDo"
        toDo.toDoDueDate = .now
        toDo.toDoPriority = .medium
        toDo.toDoCompleted = false
        toDo.toDoContent = ""
        
        if let tag = selectedFilter?.tag {
            toDo.toDoTags.append(tag)
        }
        
        modelContext.insert(toDo)
        save()
        
        selectedToDo = toDo
    }
    
    func newTag() {
        let tag = Tag()
        tag.tagID = UUID()
        tag.tagName = "New tag"
        modelContext.insert(tag)
        save()
    }
    
    func count<T>(for fetchDescriptor: FetchDescriptor<T>) -> Int {
        return (try? modelContext.fetchCount(fetchDescriptor)) ?? 0
    }

    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "ToDos":
            // returns true if they added a certain number of ToDos
            let fetchDescriptor = FetchDescriptor<ToDo>()
            let awardCount = count(for: fetchDescriptor)
            return awardCount >= award.value

        case "done":
            // returns true if they completed a certain number of ToDos
            let fetchDescriptor = FetchDescriptor<ToDo>(predicate: #Predicate<ToDo> { toDo in toDo.completed == true })
            let awardCount = count(for: fetchDescriptor)
            return awardCount >= award.value

        case "tags":
            // return true if they created a certain number of tags
            let fetchDescriptor = FetchDescriptor<Tag>()
            let awardCount = count(for: fetchDescriptor)
            return awardCount >= award.value

        default:
            // an unknown award criterion; this should never be allowed
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
}
