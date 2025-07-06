//
//  SidebarViewToolbar.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import SwiftUI

/// The toolbar for the SidebarView
struct SidebarViewToolbar: View {
    @Environment(DataController.self) private var dataController
    @State private var showingAwards = false

    var body: some View {
#if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
#endif
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }

            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }
            .sheet(isPresented: $showingAwards, content: AwardsView.init)
    }
}

#Preview {
    SidebarViewToolbar()
}
