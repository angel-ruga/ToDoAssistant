//
//  SwipeDisable.swift
//  ToDoAssistant
//
//  Created by Angel Efrain Ruiz Garcia on 08/07/25.
//

#if os(iOS)
import Foundation
import SwiftUI

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) {
            $0.next
        }.first { $0 is UIViewController } as? UIViewController
    }
}

private struct NavigationPopGestureDisabler: UIViewRepresentable {
    let disabled: Bool

    func makeUIView(context: Context) -> some UIView { UIView() }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            uiView
                .parentViewController?
                .navigationController?
                .interactivePopGestureRecognizer?.isEnabled = !disabled
        }
    }
}
public extension View {
    @ViewBuilder
    func navigationPopGestureDisabled(_ disabled: Bool) -> some View {
        background {
            NavigationPopGestureDisabler(disabled: disabled)
        }
    }
}
#endif
