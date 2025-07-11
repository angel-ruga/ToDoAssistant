//
//  DataControllerNotifications.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 09/07/25.
//

import Foundation
@preconcurrency import UserNotifications

extension DataController {

    /// Requests permissions and adds a reminder for a ToDo
    /// - Parameter toDo: The associated ToDo
    /// - Returns: False iff permission is not granted for notifications
    func addReminder(for toDo: ToDo) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotifications()

                if success {
                    try await placeReminders(for: toDo)
                } else {
                    return false
                }

            case .authorized:
                try await placeReminders(for: toDo)

            default:
                return false
            }

            return true
        } catch {
            return false
        }
    }

    /// Removes the reminder for the provided ToDo
    /// - Parameter toDo: The associated ToDo
    func removeReminders(for toDo: ToDo) {
        let center = UNUserNotificationCenter.current()
        let id = toDo.id.storeIdentifier!
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Requests notification privileges from the user
    /// - Returns: False iff failed
    private func requestNotifications() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }

    /// Adds a reminder for a ToDo
    /// - Parameter toDo: The associated ToDo
    private func placeReminders(for toDo: ToDo) async throws {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = toDo.toDoTitle
        content.subtitle = toDo.toDoContent

        let components = Calendar.current.dateComponents([.hour, .minute], from: toDo.toDoReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let id = toDo.id.storeIdentifier!
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        return try await UNUserNotificationCenter.current().add(request)
    }
}
