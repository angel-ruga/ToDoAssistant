//
//  Filter.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 18/06/25.
//

import Foundation

/// An object that stores details for filtering ToDos based on various factors.
struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var maxDueDate = Date.distantFuture
    // var tags: [Tag]?
    var tag: Tag?

    /// Returns the number of ToDos associated to the filter's tag
    var activeToDosCount: Int {
        tag?.tagActiveToDos.count ?? 0
    }

    /// A filter with all ToDos
    static var all = Filter(id: UUID(), name: "All ToDos", icon: "tray")

    /// A filter with all ToDos with due date in less that 7 days from now
    static var soon = Filter(id: UUID(), name: "ToDos due soon", icon: "clock", maxDueDate: .now.addingTimeInterval(86400 * 7)) // swiftlint:disable:this line_length

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
