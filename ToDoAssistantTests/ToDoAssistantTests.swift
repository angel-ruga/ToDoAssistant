//
//  ToDoAssistantTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

@MainActor
class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        modelContext = dataController.modelContext
    }
}
