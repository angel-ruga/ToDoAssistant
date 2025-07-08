//
//  ToDoRow.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 20/06/25.
//

import SwiftUI

/// A row for each ToDo displayed in ContentView
struct ToDoRow: View {
    @State private var viewModel: ViewModel

    init(toDo: ToDo) {
        let viewModel = ViewModel(toDo: toDo)
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationLink(value: viewModel.toDo) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)

                VStack(alignment: .leading) {
                    Text(viewModel.toDoTitle)
                        .font(.headline)
                        .lineLimit(1) // lineLimit(2...2) for two

                    Text(viewModel.toDoTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    // Text(toDo.toDoDueDate.formatted(date: .numeric, time: .omitted))
                    if viewModel.toDoCompleted {
                        Text("DONE")
                            .font(.body.smallCaps())
                    } else {
                        Text("\(viewModel.formattedTimeRemaining)")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityIdentifier(viewModel.toDoTitle)
    }
}

#Preview {
    ToDoRow(toDo: .example)
}
