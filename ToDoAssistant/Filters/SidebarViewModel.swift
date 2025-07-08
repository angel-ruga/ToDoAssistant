//
//  SidebarViewModel.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 07/07/25.
//

import Foundation
import SwiftData

extension SidebarView {

    @Observable @MainActor
    class ViewModel {
        var dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
        }

        /// An array of pre-determined filters that will always be shown
        let smartFilters: [Filter] = [.all, .soon]

        /// Returns an array of filters. One filter for each existing Tag model object.
        var tagFilters: [Filter] {
            dataController.allTags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        var tagToRename: Tag?
        var renamingTag = false
        var tagName = ""

        /// Deletes the Tag model objects selected on the list
        /// - Parameter offsets: Indices of the Tag model objects that were selected to be deleted.
        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = dataController.allTags[offset]
                dataController.delete(item)
            }
        }

        /// Deletes the specified Tag model objects
        /// - Parameter filter: The filter that contains the tag to be deleted
        func delete(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataController.delete(tag)
            dataController.save()
        }

        /// Starts the process of renaming the Tag model object contained in the filer
        /// - Parameter filter: The filter that contains the tag to be renamed
        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagName = filter.name
            renamingTag = true
        }

        /// Finishes the process of renaming the Tag model object contained in the filer
        func completeRename() {
            tagToRename?.name = tagName
            dataController.save()
        }
    }
}
