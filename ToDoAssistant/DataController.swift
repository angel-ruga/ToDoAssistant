//
//  DataController.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

enum SortType: String {
    case dueDate = "dueDate"
    case alphabetical = "alphabetical"
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
            //This save will not be executed if the previous task threw an error
            save()
        }
    }
    
    // TODO: Add user-defined filtering and sorting
    func toDosForSelectedFilter() -> [ToDo] {
        let filter = selectedFilter ?? .all
        let filterDate = filter.maxDueDate
        
        ///-----------------------------
        // Predicates
        ///-----------------------------
        
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
        
        let selfFilterPriority = self.filterPriority // Predicates do not like external objects that are not constant
        let hasPriority = #Predicate<ToDo> { toDo in
            if let priority = toDo.priority {
                if (selfFilterPriority == -1) {
                    return true
                } else {
                    return (priority == selfFilterPriority)
                }
            } else {
                return false
            }
        }
        
        let selfFilterStatus = self.filterStatus // Predicates do not like external objects that are not constant
        let selfFilterStatusDone = selfFilterStatus == Status.done
        let selfFilterStatusNotDone = selfFilterStatus == Status.notDone
        let hasStatus = #Predicate<ToDo> { toDo in
            if let completed = toDo.completed {
                if (selfFilterStatusDone == true) { // It is possible that Predicates do not like single Bool objects as expressions. Need more testing.
                    return completed == true
                } else if (selfFilterStatusNotDone == true) {
                    return completed == false
                } else {
                    return true
                }
                //return (selfFilterStatus == Status.done ? completed : selfFilterStatus == Status.notDone ? !completed : true )
            } else {
                return false
            }
        }
        
        // Need to split final predicate in parts because the compiler does not like large expressions
        let selfFilterEnabled = self.filterEnabled // Predicates do not like external objects that are not constant
        let finalPredicate1 = #Predicate<ToDo> { toDo in
            hasMaxDueDate.evaluate(toDo)
            && matchesSearch.evaluate(toDo)
            && (enableMatchesTag ? matchesTag.evaluate(toDo) : true)
        }
        let finalPredicate2 = #Predicate<ToDo> { toDo in
            (selfFilterEnabled ? hasPriority.evaluate(toDo) : true)
            && (selfFilterEnabled ? hasStatus.evaluate(toDo) : true)
        }
        let finalPredicate = #Predicate<ToDo> { toDo in
            finalPredicate1.evaluate(toDo)
            && finalPredicate2.evaluate(toDo)
        }
        
        ///-----------------------------
        // Sort Descriptor
        ///-----------------------------
        
        let azSort = SortDescriptor<ToDo>(
            \ToDo.title,
             order: self.sortAZ ? .forward : .reverse
        )
        
        let dueSoonSort = SortDescriptor<ToDo>(
            \ToDo.dueDate,
             order: self.sortDueSoonFirst ? .forward : .reverse
        )
        
        let finalSort: [SortDescriptor<ToDo>]
        
        switch (self.sortType) {
        case SortType.alphabetical:
            finalSort = [azSort, dueSoonSort]
        case SortType.dueDate:
            finalSort = [dueSoonSort, azSort]
        }
        
        ///-----------------------------
        // Fetch Descriptor
        ///-----------------------------
        
        let descriptor = FetchDescriptor<ToDo>(
            predicate: finalPredicate,
            sortBy: finalSort
        )
        
        ///-----------------------------
        // Fetch
        ///-----------------------------
        
        var allToDos: [ToDo]
        allToDos = (try? modelContext.fetch(descriptor)) ?? []
        
        return allToDos
    }
}
