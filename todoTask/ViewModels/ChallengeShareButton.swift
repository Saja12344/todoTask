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
    @EnvironmentObject private var lang: LanguageManager

    var body: some View {
        Button {
            let items = DeepLinkManager.shared.shareItems(
                roomId: challengeID,
                fromUsername: fromUsername,
                lang: lang
            )
            SharePresenter.present(items: items)
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text(lang.t(.challengeShareInvite))
                    .bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glassEffect(.regular.tint(.blue.opacity(0.3)), in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Share

enum SharePresenter {
    static func present(items: [Any]) {
        guard !items.isEmpty else { return }

        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)

        guard let presenter = topViewController() else { return }

        if let popover = activity.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(activity, animated: true)
    }

    private static func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController else {
            return nil
        }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - ShareSheet (legacy — prefer SharePresenter)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}