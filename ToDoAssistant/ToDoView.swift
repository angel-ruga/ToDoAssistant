//
//  ToDoView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 30/06/25.
//

import SwiftUI

struct ToDoView: View {
    @State var toDo: ToDo
    @Environment(DataController.self) private var dataController
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $toDo.toDoTitle, prompt: Text("Enter the ToDo title here"))
                        .font(.title)

                    Text("**Due Date:** \(toDo.toDoDueDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    
                    Text("**Status:** \(toDo.toDoStatus)")
                        .foregroundStyle(.secondary)

                }

                Picker("Priority", selection: $toDo.toDoPriority) {
                    Text("Low").tag(ToDo.Priority.low)
                    Text("Medium").tag(ToDo.Priority.medium)
                    Text("High").tag(ToDo.Priority.high)
                }
                
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
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Description", text: $toDo.toDoContent, prompt: Text("Enter the ToDo description here"), axis: .vertical)
                }
            }
        }
        .disabled(toDo.isDeleted)
    }
}

#Preview {
    ToDoView(toDo: .example)
}
