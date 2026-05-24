import SwiftUI

/// ホイールUI — ピュアアイボリー筐体 × 暗緑LCD（ログ・VMは変更しない）
struct WheelView: View {
    @ObservedObject var viewModel: WheelViewModel

    @State private var lastTouchAngleDegrees: Double?
    @State private var lastSampleDate: Date?
    @State private var angularVelocityDegPerSec: Double = 0

    /// MENU で進めるLCDアクティブ行（ローカル状態のみ・VM非変更）
    @State private var activeSlotRow: Int = 0

    @State private var isWheelInteractActive = false

    private let wheelMinSize: CGFloat = 220

    private var ringWidth: CGFloat { wheelMinSize * 0.17 }
    private var innerWheelDiameter: CGFloat { wheelMinSize - 2 * ringWidth }

    /// ラベル（MemoryCard の3行語義に準拠・UIのみ）
    private let slotLabels = ["年代・季節", "天候・時間", "場面・記憶"]

    var body: some View {
        GeometryReader { geo in
            let chassisW = min(geo.size.width - 36, 340)

            VStack(spacing: 14) {
                headerBar(chassisW: chassisW)

                lcdPanel(width: chassisW - 26)

                if !viewModel.lastCenterTapDescription.isEmpty {
                    Text(viewModel.lastCenterTapDescription)
                        .font(.system(size: 7, design: .monospaced))
                        .foregroundStyle(Color(hex: "547840").opacity(0.72))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: chassisW - 26, alignment: .leading)
                }

                wheelControlGroup

                bottomButtonRow(width: chassisW - 24)

                Text("MEM-01 · 記憶装置")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundStyle(Color(hex: "b0aca4"))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            .padding(.bottom, 18)
            .frame(width: min(chassisW + 36, geo.size.width))
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "eeeae2"),
                                    Color(hex: "e2ddd4"),
                                    Color(hex: "e8e3da")
                                ],
                                startPoint: UnitPoint(x: 0.52, y: 0),
                                endPoint: UnitPoint(x: 0.48, y: 1)
                            )
                        )
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Color(hex: "c4bfb4"), lineWidth: 1)
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.58))
                            .frame(height: 1)
                            .padding(.top, 2)
                            .padding(.horizontal, 12)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .allowsHitTesting(false)
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Rectangle()
                            .fill(Color(hex: "9e9a90"))
                            .frame(height: 3)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .allowsHitTesting(false)
                }
            }
            .shadow(color: .black.opacity(0.55), radius: 28, y: 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Header

    private func headerBar(chassisW _: CGFloat) -> some View {
        HStack {
            Text("MEMORY TUNER")
                .font(.system(size: 8, design: .monospaced))
                .tracking(3)
                .foregroundStyle(Color(hex: "8a8680"))
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(hex: "4e7a4e"))
                    .frame(width: 7, height: 7)
                Text("STANDBY")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(Color(hex: "a0998e"))
            }
        }
    }

    // MARK: - LCD

    private func lcdPanel(width lcdW: CGFloat) -> some View {
        ZStack {
            Color(hex: "090b09")
            lcdInsetShadow(width: lcdW)

            GeometryReader { _ in
                Canvas { context, size in
                    var y: CGFloat = 0
                    while y <= size.height {
                        let rr = CGRect(x: 0, y: y, width: size.width, height: 1)
                        context.fill(Path(rr), with: .color(Color.white.opacity(0.2)))
                        y += 3
                    }
                }
                .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<3, id: \.self) { row in
                    lcdSlotRow(
                        row: row,
                        label: slotLabels[row],
                        valueText: slotValue(forRow: row),
                        isActive: row == activeSlotRow
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .allowsHitTesting(false)
        }
        .frame(height: lcdHeight)
        .frame(width: lcdW)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color(hex: "141614"), lineWidth: 1)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .fill(Color(hex: "060806"))
                        .frame(height: 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
    }

    private var lcdHeight: CGFloat { 110 }

    @ViewBuilder
    private func lcdInsetShadow(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(Color.black.opacity(0.62))
            .blur(radius: 6)
            .offset(y: 3)
            .frame(width: width - 4, height: lcdHeight - 4)
            .allowsHitTesting(false)
            .blendMode(.multiply)

        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .strokeBorder(Color.black.opacity(0.45), lineWidth: 6)
            .blur(radius: 8)
            .frame(width: width - 2, height: lcdHeight - 2)
            .allowsHitTesting(false)
            .blendMode(.multiply)
    }

    private func slotValue(forRow row: Int) -> String {
        guard viewModel.cards.indices.contains(viewModel.selectedIndex) else {
            return "—"
        }
        let c = viewModel.cards[viewModel.selectedIndex]
        switch row {
        case 0: return c.line1
        case 1: return c.line2
        case 2: return c.line3
        default: return "—"
        }
    }

    private func lcdSlotRow(row _: Int, label: String, valueText: String, isActive: Bool) -> some View {
        HStack(alignment: .center, spacing: 10) {
            if isActive {
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(Color(hex: "486435"))
                    .frame(width: 2, height: 22)
                    .padding(.leading, -2)
            }

            Text(label)
                .font(.system(size: 10, weight: .light, design: .default))
                .tracking(1.8)
                .foregroundStyle(isActive ? Color(hex: "547840") : Color(hex: "222420"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            HStack(spacing: 0) {
                Text(valueText)
                    .font(.system(.caption, design: .monospaced).weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(isActive ? Color(hex: "94b86e") : Color(hex: "2a2e26"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .shadow(color: isActive ? Color(hex: "6ea046").opacity(0.45) : .clear, radius: 4, y: 0)

                if isActive {
                    BlinkingCaret()
                        .padding(.leading, 1)
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.leading, isActive ? 8 : 10)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity)
        .background(isActive ? Color(hex: "0b110a") : Color.clear)
        .cornerRadius(3)
        .allowsHitTesting(false)
    }

    // MARK: - Wheel + center

    private var wheelControlGroup: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: angularRingColors(),
                            center: .center,
                            angle: .degrees(-12)
                        )
                    )
                    .frame(width: wheelMinSize, height: wheelMinSize)
                    .overlay {
                        Circle()
                            .strokeBorder(Color(hex: "9a9690"), lineWidth: 1)
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(Color(hex: "b0aca4"), lineWidth: 1)
                            .padding(1)
                    }

                Circle()
                    .fill(Color(hex: "131514"))
                    .frame(width: innerWheelDiameter, height: innerWheelDiameter)
                    .shadow(color: .black.opacity(0.92), radius: 10, y: 10)
                    .shadow(color: .black.opacity(0.55), radius: 4, y: 2)

                notchLayer

                ZStack {
                    Circle()
                        .trim(from: 0.71, to: 0.79)
                        .stroke(Color.white.opacity(0.58), lineWidth: 2)
                        .rotationEffect(.degrees(-8))
                        .frame(width: wheelMinSize - 4, height: wheelMinSize - 4)

                    Circle()
                        .trim(from: 0.21, to: 0.29)
                        .stroke(Color.black.opacity(0.25), lineWidth: 2)
                        .rotationEffect(.degrees(-5))
                        .frame(width: wheelMinSize - 6, height: wheelMinSize - 6)
                }
                .allowsHitTesting(false)

                directionalArrows(opacity: isWheelInteractActive ? 0.55 : 0.3)

                Circle()
                    .fill(Color.orange.opacity(0.001))
                    .frame(width: wheelMinSize, height: wheelMinSize)
                    .contentShape(Circle())
                    .gesture(wheelDragGesture)
            }
            .frame(width: wheelMinSize, height: wheelMinSize)

            CenterDialButton(diameter: max(54, innerWheelDiameter - 80)) {
                viewModel.onCenterTapped()
            }
        }
        .frame(width: wheelMinSize, height: wheelMinSize)
    }

    private func angularRingColors() -> [Color] {
        [
            Color(hex: "d4d0c8"),
            Color(hex: "e4e0d6"),
            Color(hex: "dedad0"),
            Color(hex: "c8c4bc"),
            Color(hex: "e4e0d6"),
            Color(hex: "d4d0c8")
        ]
    }

    private var notchLayer: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let major = i % 3 == 0
                let h = major ? CGFloat(7) : CGFloat(5)
                RoundedRectangle(cornerRadius: 0.75, style: .continuous)
                    .fill(Color(hex: "b0aba2"))
                    .frame(width: 2, height: h)
                    .offset(y: -wheelMinSize / 2 + h / 2 + 2)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .frame(width: wheelMinSize, height: wheelMinSize)
        .allowsHitTesting(false)
    }

    private func directionalArrows(opacity: CGFloat) -> some View {
        let inset: CGFloat = ringWidth / 2 + 3
        return ZStack {
            arrowTriangle()
                .offset(y: -wheelMinSize / 2 + inset)
            arrowTriangle()
                .rotationEffect(.degrees(180))
                .offset(y: wheelMinSize / 2 - inset)
            arrowTriangle()
                .rotationEffect(.degrees(-90))
                .offset(x: -wheelMinSize / 2 + inset)
            arrowTriangle()
                .rotationEffect(.degrees(90))
                .offset(x: wheelMinSize / 2 - inset)
        }
        .foregroundStyle(Color(hex: "a8a49e").opacity(opacity))
        .frame(width: wheelMinSize, height: wheelMinSize)
        .allowsHitTesting(false)
    }

    private func arrowTriangle() -> some View {
        Path { path in
            path.move(to: CGPoint(x: 3.5, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 7))
            path.addLine(to: CGPoint(x: 7, y: 7))
            path.closeSubpath()
        }
        .frame(width: 7, height: 7)
    }

    // MARK: - Bottom buttons

    private func bottomButtonRow(width w: CGFloat) -> some View {
        HStack(spacing: 8) {
            chassisButton(width: max(82, (w - 24) / 3.2), title: "MENU", useMonospace: true) {
                advanceActiveSlotLocally()
            }
            chassisButton(width: max(82, (w - 24) / 3.2), title: "選択", useMonospace: false) {}
            chassisButton(width: max(94, (w - 24) / 2.55), title: "生成 →", useMonospace: false) {}
        }
        .frame(maxWidth: w)
    }

    private func chassisButton(width: CGFloat, title: String, useMonospace: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(useMonospace
                    ? .system(size: 11, weight: .medium, design: .monospaced)
                    : .system(size: 11, weight: .medium))
                .foregroundStyle(Color(hex: "808078"))
                .minimumScaleFactor(0.82)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .padding(.horizontal, 6)
                .background {
                    LinearGradient(
                        colors: [Color(hex: "dedad0"), Color(hex: "cac6bc")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .strokeBorder(Color(hex: "b0aca2"), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(DeviceKeyStyle())
        .frame(width: width)
    }

    private func advanceActiveSlotLocally() {
        activeSlotRow = (activeSlotRow + 1) % 3
    }

    private var wheelDragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if !isWheelInteractActive {
                    isWheelInteractActive = true
                }

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

                withAnimation(.easeOut(duration: 0.34)) {
                    isWheelInteractActive = false
                }

                withAnimation(.easeOut(duration: 0.26)) {
                    viewModel.applyWeakInertia(angularVelocityDegreesPerSecond: angularVelocityDegPerSec)
                }
                angularVelocityDegPerSec = 0
            }
    }
}

// MARK: - Subviews / styles / Color

private struct BlinkingCaret: View {
    @State private var visible = false

    var body: some View {
        Text("▌")
            .font(.system(.caption, design: .monospaced).weight(.medium))
            .foregroundStyle(Color(hex: "94b86e"))
            .opacity(visible ? 1 : 0.15)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    visible = true
                }
            }
    }
}

private struct CenterDialButton: View {
    let diameter: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("決定")
                .font(.system(size: 6.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color(hex: "8a8680"))
                .frame(width: diameter, height: diameter)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "dedad0"), Color(hex: "cac6bc")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(Circle().strokeBorder(Color(hex: "969289"), lineWidth: 2))
                        .overlay(Circle().strokeBorder(Color(hex: "b0aca2"), lineWidth: 1).padding(-0.5))
                }
                .shadow(color: .black.opacity(0.28), radius: 5, y: 3)
        }
        .buttonStyle(CenterDialPushStyle())
    }
}

private struct CenterDialPushStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .shadow(
                color: .black.opacity(0.28),
                radius: configuration.isPressed ? 2 : 5,
                y: configuration.isPressed ? 1 : 3
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct DeviceKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 1 : 0)
            .shadow(
                color: Color(hex: "969289").opacity(configuration.isPressed ? 0.15 : 0.85),
                radius: 0,
                y: configuration.isPressed ? 0 : 2
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension Color {
    /// 6桁HEX（先頭#任意）
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color(hex: "111113").ignoresSafeArea()
        WheelView(viewModel: WheelViewModel())
    }
}
#endif
