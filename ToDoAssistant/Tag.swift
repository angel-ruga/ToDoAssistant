//
//  Tag.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

@Model
class Tag {
    var id: UUID? = UUID()
    var name: String?
    var toDos: [ToDo]?
    
    init(name: String? = nil, toDos: [ToDo]? = nil) {
        self.name = name
        self.toDos = toDos
    }
}
