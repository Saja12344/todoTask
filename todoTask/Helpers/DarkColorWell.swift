//
//  DarkColorWell.swift
//  todoTask
//

import SwiftUI
import UIKit

/// Tap the color circle to open the system picker in dark mode.
struct DarkColorWell: UIViewRepresentable {
    @Binding var color: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIColorWell {
        let well = UIColorWell()
        well.overrideUserInterfaceStyle = .dark
        well.supportsAlpha = false
        well.selectedColor = UIColor(color)
        well.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        context.coordinator.well = well
        return well
    }

    func updateUIView(_ uiView: UIColorWell, context: Context) {
        uiView.overrideUserInterfaceStyle = .dark
        let ui = UIColor(color)
        if uiView.selectedColor != ui {
            uiView.selectedColor = ui
        }
    }

    final class Coordinator: NSObject {
        var parent: DarkColorWell
        weak var well: UIColorWell?

        init(parent: DarkColorWell) {
            self.parent = parent
        }

        @objc func changed(_ sender: UIColorWell) {
            guard let ui = sender.selectedColor else { return }
            parent.color = Color(ui)
        }
    }
}
