import SwiftUI

/// ホイールUI（DragGesture中心・モノクロ・装飾アニメなし）
struct WheelView: View {
    @ObservedObject var viewModel: WheelViewModel

    @State private var lastTouchAngleDegrees: Double?
    @State private var lastSampleDate: Date?
    @State private var angularVelocityDegPerSec: Double = 0

    private let wheelMinSize: CGFloat = 220
    private let centerButtonSize: CGFloat = 72

    var body: some View {
        VStack(spacing: 18) {
            Group {
                if viewModel.cards.isEmpty {
                    Text("—")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(Color(white: 0.15))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                } else {
                    VStack(spacing: 8) {
                        Text(viewModel.currentCard.line1)
                            .font(.system(.title2, design: .monospaced).weight(.semibold))
                            .foregroundStyle(Color(white: 0.12))
                            .multilineTextAlignment(.center)
                        Text(viewModel.currentCard.line2)
                            .font(.system(.body, design: .monospaced).weight(.medium))
                            .foregroundStyle(Color(white: 0.32))
                            .multilineTextAlignment(.center)
                        Text(viewModel.currentCard.line3)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(Color(white: 0.38))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 280)
                }
            }

            if !viewModel.lastCenterTapDescription.isEmpty {
                Text(viewModel.lastCenterTapDescription)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Color(white: 0.35))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            ZStack {
                Circle()
                    .strokeBorder(Color(white: 0.45), lineWidth: 2)
                    .background(Circle().fill(Color(white: 0.88)))
                    .frame(width: wheelMinSize, height: wheelMinSize)
                    .contentShape(Circle())
                    .gesture(wheelDragGesture)

                Button(action: {
                    viewModel.onCenterTapped()
                }) {
                    Circle()
                        .fill(Color(white: 0.55))
                        .overlay(
                            Circle()
                                .strokeBorder(Color(white: 0.25), lineWidth: 1)
                        )
                        .frame(width: centerButtonSize, height: centerButtonSize)
                        .overlay(
                            Text("OK")
                                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                                .foregroundStyle(Color(white: 0.12))
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(width: wheelMinSize, height: wheelMinSize)
        }
        .padding()
        .background(Color(white: 0.95))
    }

    private var wheelDragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let center = CGPoint(x: wheelMinSize / 2, y: wheelMinSize / 2)
                let touch = value.location
                let angleRad = atan2(touch.y - center.y, touch.x - center.x)
                let angleDeg = angleRad * 180 / .pi

                if let previous = lastTouchAngleDegrees {
                    var deltaDeg = angleDeg - previous
                    if deltaDeg > 180 { deltaDeg -= 360 }
                    if deltaDeg < -180 { deltaDeg += 360 }

                    let now = Date()
                    if let prior = lastSampleDate {
                        let dt = now.timeIntervalSince(prior)
                        if dt > 0.001 {
                            angularVelocityDegPerSec = deltaDeg / dt
                        }
                    }
                    lastSampleDate = now

                    viewModel.onWheelRotated(delta: deltaDeg)
                } else {
                    lastSampleDate = Date()
                }

                lastTouchAngleDegrees = angleDeg
            }
            .onEnded { _ in
                lastTouchAngleDegrees = nil
                lastSampleDate = nil

                withAnimation(.easeOut(duration: 0.26)) {
                    viewModel.applyWeakInertia(angularVelocityDegreesPerSecond: angularVelocityDegPerSec)
                }
                angularVelocityDegPerSec = 0
            }
    }
}

#if DEBUG
#Preview {
    WheelView(viewModel: WheelViewModel())
}
#endif
