//
//  ToDoView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 30/06/25.
//

import SwiftUI

/// A view that contains all the details of the selected ToDo, including options to edit them.
struct ToDoView: View {
    @State var toDo: ToDo
    @Environment(DataController.self) private var dataController
    @State var selectingDate = false
    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $toDo.toDoTitle, prompt: Text("Enter the ToDo title here"))
                        .font(.title)

                    Button("**Due Date:** \(toDo.toDoDueDate.formatted(date: .long, time: .shortened))") {
                        selectingDate.toggle()
                    }

                    if selectingDate {
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

                    TextField("Description", text: $toDo.toDoContent, prompt: Text("Enter the ToDo description here"), axis: .vertical) // swiftlint:disable:this line_length
                }
            }
            Section("Reminders") {
                Toggle("Show reminders", isOn: $toDo.toDoReminderEnabled.animation())

                if toDo.toDoReminderEnabled {
                   DatePicker(
                       "Reminder time",
                       selection: $toDo.toDoReminderTime,
                       displayedComponents: .hourAndMinute
                   )
                }
            }
        }
        .disabled(toDo.isDeleted)
        .onChange(of: toDo.hasChanges, initial: false) {
            if toDo.hasChanges {
                dataController.queueSave()
            }
        }
        .onSubmit(dataController.save)
        .toolbar {
            ToDoViewToolbar(toDo: toDo)
        }
        .alert("Oops!", isPresented: $showingNotificationsError) {
            Button("Check Settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: toDo.toDoReminderEnabled) { _, _ in
            updateReminder()
        }
        .onChange(of: toDo.toDoReminderTime) { _, _ in
            updateReminder()
        }
    }

    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }

    func updateReminder() {
        dataController.removeReminders(for: toDo)

        Task { @MainActor in
            if toDo.toDoReminderEnabled {
                let success = await dataController.addReminder(for: toDo)

                if success == false {
                    toDo.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }
}

#Preview {
    ToDoView(toDo: .example)
}
