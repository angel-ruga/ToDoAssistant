//
//  ToDoAssistantUITests.swift
//  ToDoAssistantUITests
//
//  Created by Angel Efrain Ruiz Garcia on 06/07/25.
//

import XCTest

final class ToDoAssistantUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    @MainActor
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }

    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button launch.")
        XCTAssertTrue(app.navigationBars.buttons["Filter"].exists, "There should be a Filter button launch.")
        XCTAssertTrue(app.navigationBars.buttons["Create New ToDo"].exists, "There should be a New ToDo button launch.")
    }

    func testNoToDosAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows initially.")
    }

    func testCreatingAndDeletingToDos() {
        for tapCount in 1...5 {
            app.buttons["Create New ToDo"].tap()
            app.buttons["ToDos"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }

        for tapCount in (0...4).reversed() {
            app.cells.firstMatch.swipeLeft()
            app.buttons["Delete"].tap()

            XCTAssertEqual(app.cells.count, tapCount, "There should be \(tapCount) rows in the list.")
        }
    }

    func testEditingToDoTitleUpdatesCorrectly() {
        XCTAssertEqual(app.cells.count, 0, "There should be no list rows initially.")

        app.buttons["Create New ToDo"].tap()
        app.textFields["Enter the ToDo title here"].tap()
        app.textFields["Enter the ToDo title here"].clear()
        app.typeText("My New ToDo")
        app.buttons["ToDos"].tap()
        XCTAssertTrue(app.buttons["My New ToDo"].exists, "A My New ToDo cell should now exist.")
    }

    func testEditingToDoPriorityShowsIcon() {
        app.buttons["Create New ToDo"].tap()
        app.buttons["Priority, Medium"].tap()
        app.buttons["High"].tap()

        app.buttons["ToDos"].tap()

        let identifier = "New ToDo High Priority"
        XCTAssert(app.images[identifier].exists, "A high-priority ToDo needs an icon next to it.")
    }

    func testAllAwardsShowLockedAlert() {
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()

        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            // if app.windows.element.frame.contains(award.frame) == false {
            //    app.swipeUp()
            // }
            app.buttons["OK"].tap()
        }
    }
}

extension XCUIElement {
    func clear() {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to clear text in XCUIElement.")
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
