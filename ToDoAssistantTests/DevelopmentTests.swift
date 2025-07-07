//
//  DevelopmentTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

final class DevelopmentTests: BaseTestCase {

    func testSampleDataCreationWorks() {
        dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: FetchDescriptor<Tag>()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: FetchDescriptor<ToDo>()), 50, "There should be 50 sample ToDos.")
    }
    
    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: FetchDescriptor<Tag>()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dataController.count(for: FetchDescriptor<ToDo>()), 0, "deleteAll() should leave 0 issues.")
    }

    func testExampleTagHasNoIssues() {
        let tag = Tag.example
        XCTAssertEqual(tag.toDos?.count, 0, "The example tag should have 0 issues.")
    }

    func testExampleToDoIsHighPriority() {
        let toDo = ToDo.example
        XCTAssertEqual(toDo.priority, 2, "The example ToDo should be high priority.")
    }
}
