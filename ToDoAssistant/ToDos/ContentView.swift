//
//  ContentView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 15/06/25.
//

import SwiftUI
import SwiftData

/// A view that shows a list of specific ToDos according to the selection made in SidebarView
struct ContentView: View {
    @State private var viewModel: ViewModel

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.selectedToDo) {
            ForEach(viewModel.dataController.toDosForSelectedFilter()) { toDo in
                ToDoRow(toDo: toDo)
            }
            .onDelete(perform: viewModel.delete)
        }
        .searchable(text: $viewModel.filterText, prompt: "Filter ToDos")
        .toolbar(content: ContentViewToolbar.init)
        .navigationTitle("ToDos")
        .inlineNavigationBar()
    }
}

#Preview {
    ContentView(dataController: .preview)
}
