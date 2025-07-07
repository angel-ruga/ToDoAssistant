//
//  ToDoRow.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 20/06/25.
//

import SwiftUI

/// A row for each ToDo displayed in ContentView
struct ToDoRow: View {
    @Environment(DataController.self) private var dataController
    @State var toDo: ToDo

    var body: some View {
        NavigationLink(value: toDo) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(toDo.toDoPriority == .high ? 1 : 0)
                    .accessibilityIdentifier(toDo.toDoPriority == .high ? "\(toDo.toDoTitle) High Priority" : "")

                VStack(alignment: .leading) {
                    Text(toDo.toDoTitle)
                        .font(.headline)
                        .lineLimit(1) // lineLimit(2...2) for two

                    Text(toDo.toDoTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    // Text(toDo.toDoDueDate.formatted(date: .numeric, time: .omitted))
                    if toDo.toDoCompleted {
                        Text("DONE")
                            .font(.body.smallCaps())
                    } else {
                        Text("\(toDo.formattedTimeRemaining)")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .accessibilityHint(toDo.toDoPriority == .high ? "High priority" : "")
        .accessibilityIdentifier(toDo.toDoTitle)
    }
}

#Preview {
    ToDoRow(toDo: .example)
}
