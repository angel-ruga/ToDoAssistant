//
//  PerformanceTests.swift
//  ToDoAssistantTests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import SwiftData
import XCTest
@testable import ToDoAssistant

final class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() {
        // Create a significant amount of test data
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        
        // Doing this in order to rely on the baseline for this test
        XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
