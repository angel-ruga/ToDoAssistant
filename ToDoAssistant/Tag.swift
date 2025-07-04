//
//  Tag.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 17/06/25.
//

import SwiftData
import Foundation

@Model
class Tag: Comparable {
    
    // Stored properties. Need to be optional for iCloud compatibility.
    var id: UUID? = UUID()
    var name: String?
    var toDos: [ToDo]?
    
    // Computed properties to easily get and set without optional manipulation.
    var tagID: UUID {
        get { id ?? UUID()}
        set { id = newValue }
    }
    var tagName: String {
        get { name ?? "" }
        set { name = newValue }
    }
    
    var tagActiveToDos: [ToDo] {
        let result = toDos ?? []
        return result.filter { $0.toDoCompleted == false }
    }
    
    static var example: Tag {
        let tag = Tag()
        tag.id = UUID()
        tag.name = "Example Tag"
        return tag
    }
    
    init(name: String? = nil, toDos: [ToDo]? = nil) {
        self.name = name
        self.toDos = toDos
    }
    
    // Comparable conformance
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase

        if left == right {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        } else {
            return left < right
        }
    }
}
