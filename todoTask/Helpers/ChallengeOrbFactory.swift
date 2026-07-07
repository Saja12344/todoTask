//
//  ChallengeOrbFactory.swift
//  todoTask
//

import SwiftUI

enum ChallengeOrbFactory {
    static func fromSourceGoal(_ source: OrbGoal, roomId: String, myId: String) -> OrbGoal {
        OrbGoal(
            id: UUID(),
            title: "\(source.title) ⚡",
            design: source.design,
            settings: source.settings,
            challengeInfo: ChallengeInfo(
                challengeID: roomId,
                opponentID: "",
                opponentName: "Friend",
                friendProgress: 0,
                isWinner: false,
                winnerID: nil
            )
        )
    }

    static func fromRoom(_ room: ChallengeRoom, roomId: String, myId: String) -> OrbGoal {
        let colors = room.planetGradient.compactMap { RGBAColor.fromHex($0) }
        let design = OrbDesign(
            glow: room.planetGlow,
            textureOpacity: room.planetTextureOpacity,
            textureAssetName: room.planetTextureAsset.isEmpty ? "effect1" : room.planetTextureAsset,
            gradientStops: colors.isEmpty
                ? [RGBAColor(r: 0.5, g: 0.2, b: 0.9, a: 1), RGBAColor(r: 0.2, g: 0.1, b: 0.7, a: 1)]
                : colors
        )

        let opponentName = myId == room.player1Id
            ? (room.player2Name ?? "Friend")
            : room.player1Name

        return OrbGoal(
            id: UUID(),
            title: room.planetName,
            design: design,
            challengeInfo: ChallengeInfo(
                challengeID: roomId,
                opponentID: myId == room.player1Id ? (room.player2Id ?? "") : room.player1Id,
                opponentName: opponentName,
                friendProgress: 0,
                isWinner: false,
                winnerID: room.winnerId
            )
        )
    }
}

private extension RGBAColor {
    static func fromHex(_ hex: String) -> RGBAColor? {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        return RGBAColor(
            r: Double((val >> 16) & 0xFF) / 255,
            g: Double((val >> 8) & 0xFF) / 255,
            b: Double(val & 0xFF) / 255,
            a: 1
        )
    }
}
