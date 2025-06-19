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
    var minDueDate = Date.distantFuture
    //var tags: [Tag]?
    var tag: Tag?
    
    static var all = Filter(id: UUID(), name: "All ToDos", icon: "tray")
    static var soon = Filter(id: UUID(), name: "ToDos due soon", icon: "clock", minDueDate: .now.addingTimeInterval(86400 * -7))
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
