//
//  ContentViewModel.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 08/07/25.
//

import Foundation
import SwiftData

extension ContentView {

    @dynamicMemberLookup
    @Observable @MainActor
    class ViewModel {
        var dataController: DataController

        /// Returns true if it is acceptable to reques for a review
        var shouldRequestReview: Bool {
            if dataController.count(for: FetchDescriptor<Tag>()) >= 5 {
                let reviewRequestCount = UserDefaults.standard.integer(forKey: "reviewRequestCount")
                  UserDefaults.standard.set(reviewRequestCount + 1, forKey: "reviewRequestCount")

                  if reviewRequestCount.isMultiple(of: 10) {
                      return true
                  }
            }

            return false
        }

        init(dataController: DataController) {
            self.dataController = dataController
        }

        /// Deletes the ToDo model objects selected on the list
        /// - Parameter offsets: Indices of the ToDo model objects that were selected to be deleted.
        func delete(_ offsets: IndexSet) {
            let toDos = dataController.toDosForSelectedFilter()

            for offset in offsets {
                let item = toDos[offset]
                dataController.delete(item)
            }
        }

        /// Lets us get toDo properties directly from this ViewModel class.
        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }

        /// Lets us get and set toDo properties directly from this ViewModel class.
        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get { dataController[keyPath: keyPath] }
            set { dataController[keyPath: keyPath] = newValue }
        }
    }
}
