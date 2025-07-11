//
//  InlineNavigationBar.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 10/07/25.
//

import Foundation
import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
