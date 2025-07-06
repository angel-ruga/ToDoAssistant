//
//  ToDoViewToolbar.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import SwiftUI

struct ToDoViewToolbar: View {
    @Environment(DataController.self) private var dataController
    @State var toDo: ToDo

    var openCloseButtonText: LocalizedStringKey {
        toDo.toDoCompleted ? "Re-open ToDo" : "Complete ToDo"
    }

    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = toDo.toDoTitle
            } label: {
                Label("Copy ToDo Title", systemImage: "doc.on.doc")
            }

            Button {
                toDo.toDoCompleted.toggle()
                dataController.save()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }

            Divider()

            Section("Tags") {
                TagsMenuView(toDo: toDo)
            }

        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

#Preview {
    ToDoViewToolbar(toDo: ToDo.example)
}
