//
//  PlanetColorPickerSheet.swift
//  todoTask
//

import SwiftUI

struct PlanetColorPickerSheet: View {
    @Binding var color: Color
    let title: String
    let addTitle: String
    let cancelTitle: String
    let onAdd: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                SystemColorPicker(color: $color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.darkBlu.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(cancelTitle, action: onCancel)
                        .foregroundColor(.white.opacity(0.8))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(addTitle, action: onAdd)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan)
                }
            }
            .toolbarBackground(Color.darkBlu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.darkBlu)
    }
}
