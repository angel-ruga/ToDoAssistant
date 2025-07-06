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
    @State var selectingDate = false
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $toDo.toDoTitle, prompt: Text("Enter the ToDo title here"))
                        .font(.title)

                    Button("**Due Date:** \(toDo.toDoDueDate.formatted(date: .long, time: .shortened))") {
                        selectingDate.toggle()
                    }
                    
                    if (selectingDate) {
                        DatePicker(
                            "Due Date",
                            selection: $toDo.toDoDueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    Text("**Status:** \(toDo.toDoStatus)")
                        .foregroundStyle(.secondary)

                }

                Picker("Priority", selection: $toDo.toDoPriority) {
                    Text("Low").tag(ToDo.Priority.low)
                    Text("Medium").tag(ToDo.Priority.medium)
                    Text("High").tag(ToDo.Priority.high)
                }
                
                TagsMenuView(toDo: toDo)
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
        .onChange(of: toDo.hasChanges, initial: false) {
            if (toDo.hasChanges) {
                dataController.queueSave()
            }
        }
        .onSubmit(dataController.save)
        .toolbar {
            ToDoViewToolbar(toDo: toDo)
        }
         
    }
}

#Preview {
    ToDoView(toDo: .example)
}
