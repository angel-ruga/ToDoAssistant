//
//  ToDo.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

@Model
class ToDo {
    var title: String?
    var content: String?
    var priority: Int?
    var completed: Bool?
    var dueDate: Date?
    var tags: [Tag]?
    
    init(title: String? = nil, content: String? = nil, priority: Int? = nil, completed: Bool? = nil, dueDate: Date? = nil, tags: [Tag]? = nil) {
        self.title = title
        self.content = content
        self.priority = priority
        self.completed = completed
        self.dueDate = dueDate
        self.tags = tags
    }
}
