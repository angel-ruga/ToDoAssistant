//
//  TagsMenuView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import SwiftUI

/// A view that shows the tags of the selected ToDo, with options to edit them.
struct TagsMenuView: View {
    @Environment(DataController.self) private var dataController
    @State var toDo: ToDo

    var body: some View {
        Menu {
            // show selected tags first
            ForEach(toDo.toDoTags) { tag in
                Button {
                    toDo.toDoTags.removeAll(where: {$0.tagID == tag.tagID})
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }

            // now show unselected tags
            let otherTags = dataController.missingTags(from: toDo)

            if otherTags.isEmpty == false {
                Divider()

                Section("Add Tags") {
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            toDo.toDoTags.append(tag)
                        }
                    }
                }
            }
        } label: {
            Text(toDo.toDoTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: toDo.toDoTagsList)
        }
    }
}

#Preview {
    TagsMenuView(toDo: ToDo.example)
        .environment(DataController.preview)
}
