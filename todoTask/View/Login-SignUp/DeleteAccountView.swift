//
//  DeleteAccountView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 04/12/1447 AH.
//


//
//  DeleteAccountView.swift
//

import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmation = false

    var body: some View {
        Button(role: .destructive) {
            showConfirmation = true
        } label: {
            Label("Delete Account", systemImage: "trash")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.15))
                .cornerRadius(14)
        }
        .padding(.horizontal)
        .confirmationDialog(
            "Delete Account?",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Permanently", role: .destructive) {
                Task {
                    await userVM.deleteAccount()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all your goals. This cannot be undone.")
        }
    }
}