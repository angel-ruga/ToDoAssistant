//
//  AwardTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

final class AwardTests: BaseTestCase {
    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned awards")
        }
    }

    func testCreatingToDosUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            for _ in 0..<value {
                let toDo = ToDo()
                modelContext.insert(toDo)
            }

            let matches = awards.filter { award in
                award.criterion == "ToDos" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) ToDos should unlock \(count + 1) awards.")

            dataController.deleteAll()
        }
    }

    func testClosedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            for _ in 0..<value {
                let toDo = ToDo()
                toDo.completed = true
                modelContext.insert(toDo)
            }

            let matches = awards.filter { award in
                award.criterion == "done" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) ToDos should unlock \(count + 1) awards.")

            dataController.deleteAll()
        }
    }
}
