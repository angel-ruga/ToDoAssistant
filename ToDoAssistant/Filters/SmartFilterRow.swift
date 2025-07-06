//
//  SmartFilterRow.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 05/07/25.
//

import SwiftUI

/// A row for the smart filters in SidebarView
struct SmartFilterRow: View {
    var filter: Filter

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
        }
    }
}

#Preview {
    SmartFilterRow(filter: Filter.all)
}
