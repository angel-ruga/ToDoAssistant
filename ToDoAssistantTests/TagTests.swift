//
//  TagTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

final class TagTests: BaseTestCase {

    func testCreatingTagsAndIssues() {
        let count = 10
        let toDoCount = count * count

        for _ in 0..<count {
            let tag = Tag()

            for _ in 0..<count {
                let toDo = ToDo()
                toDo.tags = [tag]
                tag.toDos?.append(toDo)

                modelContext.insert(toDo)
            }
        }

        XCTAssertEqual(dataController.count(for: FetchDescriptor<Tag>()), count, "Expected \(count) tags.")
        XCTAssertEqual(dataController.count(for: FetchDescriptor<ToDo>()), toDoCount, "Expected \(toDoCount) ToDos.")
    }

    func testDeletingTagDoesNotDeleteIssues() throws {
        dataController.createSampleData()
        let descriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(descriptor)
        dataController.delete(tags[0])
        XCTAssertEqual(dataController.count(for: FetchDescriptor<Tag>()), 4, "Expected 4 tags after deleting 1.")
        XCTAssertEqual(dataController.count(for: FetchDescriptor<ToDo>()), 50, "Expected 50 ToDos after deleting a tag")
    }
}
