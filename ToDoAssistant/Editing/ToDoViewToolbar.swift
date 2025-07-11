//
//  ToDoViewToolbar.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import CoreHaptics
import SwiftUI

/// The toolbar for the ToDoView
struct ToDoViewToolbar: View {
    @Environment(DataController.self) private var dataController
    @State var toDo: ToDo
    @State private var engine = try? CHHapticEngine()

    var openCloseButtonText: LocalizedStringKey {
        toDo.toDoCompleted ? "Re-open ToDo" : "Complete ToDo"
    }

    var body: some View {
        Menu {
            Button("Copy ToDo Title", systemImage: "doc.on.doc", action: copyToClipboard)

            Button(action: toggleCompleted) {
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

    func toggleCompleted() {
        toDo.toDoCompleted.toggle()
        dataController.save()

        if toDo.toDoCompleted {
            // UINotificationFeedbackGenerator().notificationOccurred(.success)
            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 0)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 1)
                // use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )
                // create a continuous haptic event starting immediately and lasting one second
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [sharpness, intensity],
                    relativeTime: 0.125,
                    duration: 1
                )
                let pattern = try CHHapticPattern(events: [event2, event1], parameterCurves: [parameter])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                // playing haptics didn't work, but that's okay
            }
        }
    }

    func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = toDo.toDoTitle
        #else
        NSPasteboard.general.prepareForNewContents()
        NSPasteboard.general.setString(toDo.toDoTitle, forType: .string)
        #endif
    }
}

#Preview {
    ToDoViewToolbar(toDo: ToDo.example)
}
