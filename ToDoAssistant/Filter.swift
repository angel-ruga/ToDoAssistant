//
//  Filter.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 18/06/25.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var maxDueDate = Date.distantFuture
    // var tags: [Tag]?
    var tag: Tag?
    
    var activeToDosCount: Int {
        tag?.tagActiveToDos.count ?? 0
    }
    
    static var all = Filter(id: UUID(), name: "All ToDos", icon: "tray")
    static var soon = Filter(id: UUID(), name: "ToDos due soon", icon: "clock", maxDueDate: .now.addingTimeInterval(86400 * 7)) // swiftlint:disable:this line_length
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
