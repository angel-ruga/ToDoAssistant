//
//  ToDo.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

/// Model class for the ToDos this whole app is about
@Model
class ToDo: Comparable {
    enum Priority: Int, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
    }

    // Stored properties. Need to be optional for iCloud compatibility.
    var title: String?
    var content: String?
    var priority: Int?
    var completed: Bool?
    var dueDate: Date?
    var tags: [Tag]?

    // Computed properties to easily get and set without optional manipulation.
    var toDoTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    var toDoContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    var toDoPriority: Priority {
        get { Priority(rawValue: priority ?? 0) ?? Priority.low }
        set { priority = newValue.rawValue }
    }
    var toDoCompleted: Bool {
        get { completed ?? false }
        set { completed = newValue }
    }
    var toDoDueDate: Date {
        get { dueDate ?? .distantFuture }
        set { dueDate = newValue }
    }
    var toDoTags: [Tag] {
        get {
            let result = tags ?? []
            return result.sorted()
        }
        set { tags = newValue }
    }

    /// Returns the formatted remaining time before the ToDo's due date.
    ///
    /// It only returns the number of units of the biggest time unit.
    var formattedTimeRemaining: String {
        if toDoDueDate < Date.now {
            return "OVERDUE"
        }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: .now, to: toDoDueDate) // swiftlint:disable:this line_length
        let componentValues = [components.year, components.month, components.day, components.hour, components.minute, components.second] // swiftlint:disable:this line_length
        let componentStrs = ["year", "month", "day", "hour", "minute", "second"]
        for idx in (0..<componentValues.count) {
            if let value = componentValues[idx] {
                if value != 0 {
                    return "\(value) \(componentStrs[idx])\(abs(value) > 1 ? "s" : "")"
                }
            }
        }
        return "unknown time remaining"
    }

    /// Returns the ToDo completion status as a string for viewing purposes
    var toDoStatus: String {
        if toDoCompleted {
            return "Done"
        } else {
            return "Pending"
        }
    }

    /// Return a formatterd string naming the tags the ToDo has
    var toDoTagsList: String {
        if toDoTags.count == 0 {
            return "No tags"
        } else {
            return toDoTags.map(\.tagName).formatted()
        }
    }

    /// Example ToDo for testing and preview purposes
    static var example: ToDo {
        let toDo = ToDo()
        toDo.title = "Example ToDo"
        toDo.content = "This is an example ToDo."
        toDo.priority = 2
        toDo.dueDate = .distantFuture
        return toDo
    }

    init(title: String? = nil, content: String? = nil, priority: Int? = nil, completed: Bool? = false, dueDate: Date? = nil, tags: [Tag]? = nil) { // swiftlint:disable:this line_length
        self.title = title
        self.content = content
        self.priority = priority
        self.completed = completed
        self.dueDate = dueDate
        self.tags = tags
    }

    // Comparable conformance
    public static func < (lhs: ToDo, rhs: ToDo) -> Bool {
        let left = lhs.toDoTitle.localizedLowercase
        let right = rhs.toDoTitle.localizedLowercase

        if left == right {
            return lhs.toDoDueDate < rhs.toDoDueDate
        } else {
            return left < right
        }
    }

    /// Removes the specified Tag object from this ToDo object
    /// - Parameter tag: Tag to be removed
    public func removeTag(_ tag: Tag) {
        toDoTags.removeAll(where: {$0 == tag})
    }

    /// Converts the priority property into a String that can be shown to the user.
    /// - Parameter priority: The priority enum value
    /// - Returns: The resulting string
    static func priority2str (_ priority: Priority) -> String {
        switch priority {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
