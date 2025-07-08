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
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
                    .navigationPopGestureDisabled(true)
            } detail: {
                DetailView()
                    .navigationPopGestureDisabled(true)
            }
            .environment(\.modelContext, dataController.modelContext)
            .environment(dataController)
            .onChange(of: scenePhase, initial: false) {
                if scenePhase != .active {
                    dataController.save()
                }
            }
        }
    }
}
