//
//  SidebarView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 18/06/25.
//

import SwiftUI
import SwiftData

/// A view that shows a list of filters that group ToDos in different ways
struct SidebarView: View {
    @Environment(DataController.self) private var dataController

    /// An array of pre-determined filters that will always be shown
    let smartFilters: [Filter] = [.all, .soon]
    @Query(sort: \Tag.name) var tags: [Tag]

    /// Returns an array of filters. One filter for each existing Tag model object.
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }

    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""

    var body: some View {
        @Bindable var dataController = dataController
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: rename, delete: delete)
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $renamingTag) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $tagName)
        }
        .navigationTitle("Filters")

    }

    /// Deletes the Tag model objects selected on the list
    /// - Parameter offsets: Indices of the Tag model objects that were selected to be deleted.
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
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

#Preview {
    SidebarView()
        .environment(DataController.preview)
}
