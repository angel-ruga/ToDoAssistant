//
//  NoToDoView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 30/06/25.
//

import SwiftUI

/// A view that is shown when no ToDo is selected
struct NoToDoView: View {
    @Environment(DataController.self) private var dataController

    var body: some View {
        Text("No ToDo Selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New ToDo", action: dataController.newToDo)
    }
}

#Preview {
    NoToDoView()
        .environment(DataController.preview)
}
