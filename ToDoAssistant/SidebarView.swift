//
//  SidebarView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 18/06/25.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    
    @Environment(DataController.self) private var dataController
    //@Environment(\.modelContext) private var modelContext
    let smartFilters: [Filter] = [.all, .soon]
    @Query(sort: \Tag.name) var tags: [Tag]
    
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.id ?? UUID(), name: tag.name ?? "No name", icon: "tag", tag: tag)
        }
    }
    
    var body: some View {
        @Bindable var dataController = dataController
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
                //Text("\(tags.count)")
            }
            Section("Tags") {
                ForEach(tagFilters) { filter in
                    NavigationLink(value: filter) {
                        Label(filter.name, systemImage: filter.icon)
                    }
                }
            }
        }
        .toolbar {
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
        }
    }
}

#Preview {
    SidebarView()
        .environment(DataController.preview)
}
