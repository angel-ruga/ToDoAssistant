//
//  ContentView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 15/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(DataController.self) private var dataController
    
    var body: some View {
        @Bindable var dataController = dataController
        
        List(selection: $dataController.selectedToDo) {
            ForEach(dataController.toDosForSelectedFilter()) { toDo in
                ToDoRow(toDo: toDo)
            }
            .onDelete(perform: delete)
        }
        .searchable(text: $dataController.filterText, prompt: "Filter ToDos")
        .toolbar {
            
            Button(action: dataController.newToDo) {
                Label("New ToDo", systemImage: "square.and.pencil")
            }
            
            Menu {
                Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                    dataController.filterEnabled.toggle()
                }

                Divider()

                Menu {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Due Date").tag(SortType.dueDate)
                        Text("Alphabetical").tag(SortType.alphabetical)
                    }
                } label: {
                    Button(action: {}) {
                        Text("Sort by")
                        Text(dataController.sortType == SortType.alphabetical ? "Alphabetical" : "Due Date")
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                
                Menu {
                    if (dataController.sortType == .dueDate) {
                        Picker("Sort Order", selection: $dataController.sortDueSoonFirst) {
                            Text("Due soon first").tag(true)
                            Text("Due soon last").tag(false)
                        }
                    } else if (dataController.sortType == .alphabetical) {
                        Picker("Sort Order", selection: $dataController.sortAZ) {
                            Text("A to Z").tag(true)
                            Text("Z to A").tag(false)
                        }
                    }
                } label: {
                    Button(action: {}) {
                        Text("Sort Order")
                        if (dataController.sortType == .dueDate) {
                            Text(dataController.sortDueSoonFirst == true ? "Due soon first" : "Due soon last")
                        } else if (dataController.sortType == .alphabetical) {
                            Text(dataController.sortAZ == true ? "A to Z" : "Z to A")
                        }
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                
                Divider()

                Menu {
                    Picker("Status", selection: $dataController.filterStatus) {
                        Text("All").tag(Status.all)
                        Text("Done").tag(Status.done)
                        Text("Not done").tag(Status.notDone)
                    }
                } label: {
                    Button(action: {}) {
                        Text("Status")
                        Text("\(dataController.filterStatus.rawValue )")
                        Image(systemName: "checkmark")
                    }
                }
                .disabled(dataController.filterEnabled == false)
                
                Menu {
                    Picker("Priority", selection: $dataController.filterPriority) {
                        Text("All").tag(-1)
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                } label: {
                    Button(action: {}) {
                        Text("Priority")
                        Text(dataController.filterPriority == -1 ? "All" : ToDo.priority2str(ToDo.Priority.init(rawValue: dataController.filterPriority)!))
                        Image(systemName: "exclamationmark")
                    }
                }
                .disabled(dataController.filterEnabled == false)
                
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)
            }
            .menuActionDismissBehavior(.disabled)
        }
        .navigationTitle("ToDos")
        //.toolbarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func delete(_ offsets: IndexSet) {
        let toDos = dataController.toDosForSelectedFilter()
        
        for offset in offsets {
            let item = toDos[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
