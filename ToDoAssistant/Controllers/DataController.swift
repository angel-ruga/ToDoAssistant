//
//  DataController.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation
#if DEBUG
        import SwiftUI
#endif

enum SortType: String {
    case dueDate
    case alphabetical
}

enum Status: String {
    case all = "All"
    case done = "Done"
    case notDone = "Not Done"
}

/// An environment singleton responsible for managing our SwiftData models, including handling, saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
@Observable @MainActor
class DataController {

    /// The lone SwiftData container used to store all our data.
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

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false) {

        // Gotta check behavior of CoreData automaticallyMergesChangesFromParent and mergePolicy translated to SwiftData

        let schema = Schema([ToDo.self, Tag.self])
        let config: ModelConfiguration
        // For testing and previewing purposes, we create a
        // temporary, in-memory database so our data is
        // destroyed after the app finishes running.
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
#if DEBUG
        UIView.setAnimationsEnabled(false)
        if CommandLine.arguments.contains("enable-testing") {
            self.deleteAll()
        }
#endif
    }

    /// Returns a DataController instance stored in memory only for preview and testing purposes
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    /// Saves our SwiftData context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        saveTask?.cancel() // Just in case this method was called in .onSubmit(dataController.save)
        if modelContext.hasChanges {
            try? modelContext.save()
        }
    }

    /// Deletes the provided model object from storage
    /// - Parameter object: Object to be deleted
    func delete<T: PersistentModel>(_ object: T) {
        modelContext.delete(object)
        save()
    }

    /// Deletes all model objects (ToDos and Tags) from storage
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

    /// Creates sample ToDo and Tag model objects for testing purposes
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

    /// Returns all the existing tags not on the provided ToDo
    /// - Parameter toDo: The specified ToDo
    /// - Returns: The array of Tags not on the specified ToDo
    func missingTags(from toDo: ToDo) -> [Tag] {
        let request = FetchDescriptor<Tag>()
        let allTags = (try? modelContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(toDo.toDoTags)

        return difference.sorted()
    }

    /// Schedules a save of the model objects in 3 minutes from now
    func queueSave() {
        // Cancel the previous save task if it already was in progress
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            // This save will not be executed if the previous task threw an error
            save()
        }
    }

    /// Returns the sort descriptor array that will be used for the data fetch, based on the current filter status.
    /// - Returns: Sort descriptor array
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

    /// Runs a fetch with various predicates and sort descriptors that filter and order the user's ToDos based
    /// on tag, title and content text, date, priority, and completion status.
    /// - Returns: An array of all matching ToDos.
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

    /// Creates a new ToDo model object and selects it
    func newToDo() {
        let toDo = ToDo()
        toDo.toDoTitle = "New ToDo"
        toDo.toDoDueDate = .now
        toDo.toDoPriority = .medium
        toDo.toDoCompleted = false
        toDo.toDoContent = ""

        // If we're currently browsing a user-created tag, immediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of issues they see.
        if let tag = selectedFilter?.tag {
            toDo.toDoTags.append(tag)
        }

        modelContext.insert(toDo)
        save()

        selectedToDo = toDo
    }

    /// Creates a new Tag model object
    func newTag() {
        let tag = Tag()
        tag.tagID = UUID()
        tag.tagName = "New tag"
        modelContext.insert(tag)
        save()
    }

    /// Returns the count of the requested stored model objects
    /// - Parameter fetchDescriptor: Describes the rules for the fetch before the count
    /// - Returns: Number of matched object model
    func count<T>(for fetchDescriptor: FetchDescriptor<T>) -> Int {
        return (try? modelContext.fetchCount(fetchDescriptor)) ?? 0
    }

    /// Returns true iff the specified award has been earned
    /// - Parameter award: The specified award
    /// - Returns: Wether the award has been earned
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
