//
//  SystemColorPicker.swift
//  todoTask
//

import SwiftUI
import UIKit

/// Full-screen system color UI (grid / spectrum), not the tiny ColorPicker circle.
struct SystemColorPicker: UIViewControllerRepresentable {
    @Binding var color: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.overrideUserInterfaceStyle = .dark
        picker.supportsAlpha = false
        picker.selectedColor = UIColor(color)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIColorPickerViewController, context: Context) {
        let ui = UIColor(color)
        if picker.selectedColor != ui {
            picker.selectedColor = ui
        }
    }

    final class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: SystemColorPicker

        init(parent: SystemColorPicker) {
            self.parent = parent
        }

        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            parent.color = Color(viewController.selectedColor)
        }

        func colorPickerViewController(
            _ viewController: UIColorPickerViewController,
            didSelect color: UIColor,
            continuously: Bool
        ) {
            parent.color = Color(color)
        }
    }
}
