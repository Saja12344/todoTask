//
//  ChallengeShareButton.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 12/09/1447 AH.
//


//
//  ChallengeShareButton.swift
//  todoTask
//

import SwiftUI

// MARK: - زر الشير يحطينه في ChallengeFriendV بعد ما يتولد التحدي
struct ChallengeShareButton: View {
    let challengeID: String
    let fromUsername: String

    @State private var showShare = false
    @State private var shareURL: URL? = nil

    var body: some View {
        Button {
            if let url = DeepLinkManager.shared.generateLink(
                challengeID: challengeID,
                fromUsername: fromUsername
            ) {
                shareURL = url
                showShare = true
            }
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Challenge")
                    .bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassEffect(.regular.tint(.blue.opacity(0.3)), in: .capsule)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showShare) {
            if let url = shareURL {
                ShareSheet(items: [
                    "Join my challenge on todoTask! 🔥\n\(url.absoluteString)"
                ])
            }
        }
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}