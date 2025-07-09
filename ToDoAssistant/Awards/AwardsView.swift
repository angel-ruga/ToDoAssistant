//
//  AwardsView.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 04/07/25.
//

import SwiftUI

/// A view that shows the all the earnable awards
struct AwardsView: View {
    @Environment(DataController.self) private var dataController

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))] // Might need  to adjust that 100 later
    }

    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    private var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    private func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    private func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked"
    }
}

#Preview {
    AwardsView()
        .environment(DataController.preview)
}
