//
//  ToDoRowViewModel.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 08/07/25.
//

import Foundation
import SwiftData

extension ToDoRow {

    @dynamicMemberLookup
    @Observable @MainActor
    class ViewModel {
        var toDo: ToDo

        init(toDo: ToDo) {
            self.toDo = toDo
        }

        var iconOpacity: Double {
            toDo.toDoPriority == .high ? 1 : 0
        }

        var iconIdentifier: String {
            toDo.toDoPriority == .high ? "\(toDo.toDoTitle) High Priority" : ""
        }

        var accessibilityHint: String {
            toDo.toDoPriority == .high ? "High priority" : ""
        }

        /// Returns the formatted remaining time before the ToDo's due date.
        ///
        /// It only returns the number of units of the biggest time unit.
        var formattedTimeRemaining: String {
            if toDo.toDoDueDate < Date.now {
                return "OVERDUE"
            }

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: .now, to: toDo.toDoDueDate) // swiftlint:disable:this line_length
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

        /// Lets us get toDo properties directly from this ViewModel class.
        subscript<Value>(dynamicMember keyPath: KeyPath<ToDo, Value>) -> Value {
            toDo[keyPath: keyPath]
        }
    }
}
