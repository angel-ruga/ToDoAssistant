//
//  ContentView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 15/06/25.
//

import SwiftUI
import SwiftData
import StoreKit

/// A view that shows a list of specific ToDos according to the selection made in SidebarView
struct ContentView: View {
    @State private var viewModel: ViewModel
    @Environment(\.requestReview) var requestReview

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
        .onAppear(perform: askForReview)
        .navigationTitle("ToDos")
        .inlineNavigationBar()
    }

    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
}

#Preview {
    ContentView(dataController: .preview)
        .environment(DataController.preview)
}
