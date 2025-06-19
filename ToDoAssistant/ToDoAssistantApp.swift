//
//  ToDoAssistantApp.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 15/06/25.
//

import SwiftData
import SwiftUI

@main
struct ToDoAssistantApp: App {
    @State var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.modelContext, dataController.modelContext)
            .environment(dataController)
        }
    }
}

/*
 struct ToDoAssistantApp: App {
     let container: ModelContainer
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
         .modelContainer(container)
     }
     
     init() {
         let schema = Schema([ToDo.self, Tag.self])
         let config = ModelConfiguration("MyToDos", schema: schema, url: URL.documentsDirectory.appending(path: "MyToDos.store"))
         do {
             container = try ModelContainer(for: ToDo.self, configurations: config)
         } catch {
             fatalError("Could not configure the container")
         }
         DataController.container = container
     }
 }
 */
