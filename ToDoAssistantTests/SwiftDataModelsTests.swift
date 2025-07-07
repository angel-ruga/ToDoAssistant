//
//  SwiftDataModelsTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

final class SwiftDataModelsTests: BaseTestCase {

    func testToDoTitleUnwrap() {
        let toDo = ToDo()

        toDo.title = "Example ToDo"
        XCTAssertEqual(toDo.toDoTitle, "Example ToDo", "Changing title should also change toDoTitle.")

        toDo.toDoTitle = "Updated ToDo"
        XCTAssertEqual(toDo.title, "Updated ToDo", "Changing toDoTitle should also change title.")
    }

    func testToDoContentUnwrap() {
        let toDo = ToDo()

        toDo.content = "Example ToDo"
        XCTAssertEqual(toDo.toDoContent, "Example ToDo", "Changing content should also change toDoContent.")

        toDo.toDoContent = "Updated ToDo"
        XCTAssertEqual(toDo.content, "Updated ToDo", "Changing toDoContent should also change content.")
    }

    func testToDoDueDateUnwrap() {
        let toDo = ToDo()
        let testDate1 = Date.now
        let testDate2 = Date.distantFuture

        toDo.dueDate = testDate1
        XCTAssertEqual(toDo.toDoDueDate, testDate1, "Changing dueDate should also change toDoDueDate.")

        toDo.toDoDueDate = testDate2
        XCTAssertEqual(toDo.dueDate, testDate2, "Changing toDoDueDate should also change dueDate.")
    }

    func testToDoPriorityUnwrap() {
        let toDo = ToDo()

        toDo.priority = 2
        let expPriority = ToDo.Priority.init(rawValue: 2)
        XCTAssertEqual(toDo.toDoPriority, expPriority, "Changing priority should also change toDoPriority.")

        toDo.toDoPriority = .medium
        let expPriorityValue = ToDo.Priority.medium.rawValue
        XCTAssertEqual(toDo.priority, expPriorityValue, "Changing toDoPriority should also change priority.")
    }

    func testToDoCompletedUnwrap() {
        let toDo = ToDo()

        toDo.completed = true
        XCTAssertEqual(toDo.toDoCompleted, true, "Changing completed should also change toDoCompleted.")

        toDo.toDoCompleted = false
        XCTAssertEqual(toDo.completed, false, "Changing toDoCompleted should also change completed.")
    }

    func testToDoTagsUnwrap() {
        let toDo = ToDo()
        let tag = Tag()

        XCTAssertEqual(toDo.toDoTags.count, 0, "A new ToDo should have no tags.")

        toDo.toDoTags.append(tag)
        XCTAssertEqual(toDo.toDoTags.count, 1, "Adding 1 tag to a ToDo should result in toDoTags having count 1.")
    }

    func testToDoTagsList() {
        let toDo = ToDo()
        let tag = Tag()

        tag.name = "My Tag"
        toDo.toDoTags.append(tag)

        XCTAssertEqual(toDo.toDoTagsList, "My Tag", "Adding 1 tag to a ToDo should make toDoTagsList be My Tag.")
    }

    func testToDoSortingIsStable() {
        let toDo1 = ToDo()
        toDo1.title = "B ToDo"
        toDo1.dueDate = .now

        let toDo2 = ToDo()
        toDo2.title = "B ToDo"
        toDo2.dueDate = .now.addingTimeInterval(1)

        let toDo3 = ToDo()
        toDo3.title = "A ToDo"
        toDo3.dueDate = .now.addingTimeInterval(100)

        let allToDos = [toDo1, toDo2, toDo3]
        let sorted = allToDos.sorted()

        XCTAssertEqual([toDo3, toDo1, toDo2], sorted, "Sorting ToDo arrays should use name then due date.")
    }

    func testTagIdUnwrap() {
        let tag = Tag()
        let exampleId1 = UUID()
        let exampleId2 = UUID()

        tag.id = exampleId1
        XCTAssertEqual(tag.tagID, exampleId1, "Changing id should also change tagID.")

        tag.tagID = exampleId2
        XCTAssertEqual(tag.id, exampleId2, "Changing tagID should also change id.")
    }

    func testTagNameUnwrap() {
        let tag = Tag()

        tag.name = "Example Tag"
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName.")

        tag.tagName = "Updated Tag"
        XCTAssertEqual(tag.name, "Updated Tag", "Changing tagName should also change name.")
    }

    func testTagActiveToDos() {
        let tag = Tag()
        let toDo = ToDo()

        XCTAssertEqual(tag.tagActiveToDos.count, 0, "A new tag should have 0 active ToDos.")

        tag.toDos?.append(toDo)
        XCTAssertEqual(tag.tagActiveToDos.count, 1, "A tag with 1 new ToDo should have 1 active ToDo.")

        toDo.toDoCompleted = true
        XCTAssertEqual(tag.tagActiveToDos.count, 0, "A tag with 1 completed ToDo should have 0 active ToDos.")
    }

    func testTagSortingIsStable() {
        let tag1 = Tag()
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag()
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-DC22-4463-8C69-7275D037C13D")

        let tag3 = Tag()
        tag3.name = "A Tag"
        tag3.id = UUID()

        let allTags = [tag1, tag2, tag3]
        let sorted = allTags.sorted()

        XCTAssertEqual([tag3, tag1, tag2], sorted, "Sorting Tag arrays should use name then UUID string.")
    }

}
