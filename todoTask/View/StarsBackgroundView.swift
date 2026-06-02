//
//  StarsBackgroundView.swift
//  todoTask
//
//  Created by شهد عبدالله القحطاني on 16/12/1447 AH.
//


//  SpaceComponents.swift
//  todoTask

import SwiftUI

struct StarsBackgroundView: View {
    private let stars: [(CGFloat, CGFloat, CGFloat)] = (0..<130).map { _ in
        (CGFloat.random(in: 0...1),
         CGFloat.random(in: 0...1),
         CGFloat.random(in: 0.3...1.4))
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<stars.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: stars[i].2, height: stars[i].2)
                    .position(
                        x: stars[i].0 * geo.size.width,
                        y: stars[i].1 * geo.size.height
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

struct RocketSprite: View {
    let color: Color
    let label: String
    let progress: Double

    @State private var flameSize: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 3) {
            if !label.isEmpty {
                Text(label).font(.caption2.bold()).foregroundColor(color)
            }
            ZStack(alignment: .bottom) {
                // لهب
                Ellipse()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 10, height: 18 * flameSize)
                    .offset(y: 10)
                    .blur(radius: 1.5)

                // جسم الصاروخ
                RocketBodyShape()
                    .fill(color)
                    .frame(width: 24, height: 52)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 8, height: 8)
                            .offset(y: -8)
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.28).repeatForever()) {
                flameSize = 1.45
            }
        }
    }
}

struct RocketBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: w/2, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: h*0.5),
                       control: CGPoint(x: w*1.1, y: h*0.18))
        p.addLine(to: CGPoint(x: w, y: h*0.8))
        p.addLine(to: CGPoint(x: w*0.65, y: h*0.58))
        p.addLine(to: CGPoint(x: w*0.65, y: h))
        p.addLine(to: CGPoint(x: w*0.35, y: h))
        p.addLine(to: CGPoint(x: w*0.35, y: h*0.58))
        p.addLine(to: CGPoint(x: 0, y: h*0.8))
        p.addLine(to: CGPoint(x: 0, y: h*0.5))
        p.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                       control: CGPoint(x: w * -0.1, y: h*0.18))
        return p
    }
}

struct TrailPath: View {
    let x: CGFloat
    let progress: Double
    let height: CGFloat
    let color: Color

    var body: some View {
        let startY = height * 0.84
        let endY   = height * 0.18
        let currentY = startY - (startY - endY) * progress

        Path { path in
            path.move(to: CGPoint(x: x, y: startY))
            path.addLine(to: CGPoint(x: x, y: currentY + 26))
        }
        .stroke(color.opacity(0.3),
                style: StrokeStyle(lineWidth: 2.5, dash: [6, 5]))
        .animation(.easeOut(duration: 0.35), value: progress)
        .allowsHitTesting(false)
    }
}

// Extension مساعد لتحويل hex → Color
extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        guard h.count == 6 else { return nil }
        var val: UInt64 = 0
        Scanner(string: h).scanHexInt64(&val)
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >>  8) & 0xFF) / 255,
            blue:  Double( val        & 0xFF) / 255
        )
    }
}