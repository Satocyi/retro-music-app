import OSLog
import SwiftUI

/// Memory Tuner — 黒ホイール版レトロデバイス（web版視覚基準・見た目移植 第一段階）
struct MemoryTunerView: View {
    private static let log = Logger(subsystem: "dev.wheelprototype.app", category: "MemoryTuner")

    private struct SlotDefinition {
        let label: String
        let options: [String]
        let defaultIndex: Int
    }

    private static let slots: [SlotDefinition] = [
        SlotDefinition(label: "年", options: ["1992", "1993", "1994", "1995", "1996"], defaultIndex: 2),
        SlotDefinition(label: "季節", options: ["春", "夏", "秋", "冬"], defaultIndex: 0),
        SlotDefinition(label: "天気", options: ["晴れ", "曇り", "雨", "雪"], defaultIndex: 0),
        SlotDefinition(label: "場所", options: ["家", "学校", "街", "海"], defaultIndex: 0),
        SlotDefinition(label: "情景", options: ["ひとり", "友達", "家族", "静か"], defaultIndex: 0)
    ]

    private static let notchAngle: Double = 30
    private static let wheelNotchCount = 40

    @State private var activeSlotIndex = 0
    @State private var slotValueIndices: [Int]
    @State private var lastGesture = "none"
    @State private var statusLine = ""
    @State private var okPressed = false

    @State private var lastTouchAngleDegrees: Double?
    @State private var lastSampleDate: Date?
    @State private var angularVelocityDegPerSec: Double = 0
    @State private var notchAccumulator: Double = 0
    @State private var isWheelInteractActive = false

    init() {
        _slotValueIndices = State(initialValue: Self.slots.map(\.defaultIndex))
    }

    var body: some View {
        GeometryReader { geo in
            let padDeviceTop: CGFloat = 20
            let padDeviceBottom: CGFloat = 6
            let innerClear = geo.size.height - padDeviceTop - padDeviceBottom

            let lcdW = geo.size.width - 56
            let lcdH = lcdW * 0.42
            let wheelGap: CGFloat = 14
            let wheelTail: CGFloat = 2
            let railBottom = min(max(geo.size.height * (18.95 / 100), 134), 148)

            let wheelCapV = innerClear - lcdH - wheelGap - wheelTail - railBottom - 26
            let wheelCapH = geo.size.width - 8
            let wheelFlat = min(wheelCapH, wheelCapV)

            let slackBelow = innerClear - lcdH - wheelGap - wheelTail - wheelFlat - 26

            let stretchCap = min(max(geo.size.height * (17.95 / 100), 108), 148)
            let stretchY = min(max(slackBelow - railBottom, 0), stretchCap)
            let bottomTail = slackBelow - stretchY

            let wheelStretchScale = (wheelFlat + stretchY) / wheelFlat

            ZStack(alignment: .topLeading) {
                deviceChassisBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    statusLEDRow
                        .padding(.top, geo.safeAreaInsets.top + 18)
                        .padding(.horizontal, 28)

                    lcdBezel(width: geo.size.width - 56)
                        .padding(.top, 10)
                        .padding(.horizontal, 28)

                    Color.clear
                        .frame(height: wheelGap)
                        .frame(maxWidth: .infinity)

                    wheelMountSection(diameter: wheelFlat)
                        .scaleEffect(x: 1, y: wheelStretchScale, anchor: .center)
                        .padding(.bottom, wheelTail)

                    Color.clear
                        .frame(height: max(0, bottomTail))
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, max(geo.safeAreaInsets.bottom, 6))

                #if DEBUG
                debugHUD
                    .padding(.top, geo.safeAreaInsets.top + 6)
                    .padding(.leading, 10)
                #endif
            }
        }
    }

    // MARK: - Device chassis (web: brushed silver body)

    private var deviceChassisBackground: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "d6d6d6"), location: 0),
                        .init(color: Color(hex: "bebebe"), location: 0.18),
                        .init(color: Color(hex: "b6b6b6"), location: 0.38),
                        .init(color: Color(hex: "c6c6c6"), location: 0.58),
                        .init(color: Color(hex: "cecece"), location: 0.78),
                        .init(color: Color(hex: "c2c2c2"), location: 1)
                    ],
                    startPoint: UnitPoint(x: 0.35, y: 0),
                    endPoint: UnitPoint(x: 0.65, y: 1)
                )

                BrushedMetalGrain()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: UnitPoint(x: 0.3, y: 0),
                        endPoint: UnitPoint(x: 0.7, y: 0.55)
                    )
                    .frame(height: geo.size.height * 0.42)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Status LED (web: top-right green dot)

    private var statusLEDRow: some View {
        HStack {
            Spacer()
            Circle()
                .fill(Color(hex: "44aa44"))
                .frame(width: 6, height: 6)
                .shadow(color: Color(hex: "44aa44").opacity(0.9), radius: 4)
        }
    }

    // MARK: - LCD bezel + dot matrix screen

    private func lcdBezel(width lcdW: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "181818"), Color(hex: "121212")],
                startPoint: .top,
                endPoint: .bottom
            )

            dotMatrixPanel(width: lcdW - 6)
                .padding(3)
        }
        .frame(width: lcdW, height: lcdW * 0.42)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .shadow(color: .black.opacity(0.85), radius: 2.5, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
        }
    }

    private func dotMatrixPanel(width lcdW: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0a1a0a"), Color(hex: "0d1f0d")],
                startPoint: .top,
                endPoint: .bottom
            )

            ScanlineOverlay()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color(hex: "78ff78").opacity(0.04), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: lcdW * 0.42 * 0.35)
                Spacer()
            }
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("MEMORY TUNER")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(Color(hex: "4aff4a").opacity(0.85))
                        .shadow(color: Color(hex: "00ff00").opacity(0.6), radius: 3)
                    Spacer()
                    Text("●STANDBY")
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundStyle(Color(hex: "3acc3a"))
                        .shadow(color: Color(hex: "00cc00").opacity(0.5), radius: 2)
                }
                .padding(.bottom, 6)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color(hex: "1a4a1a"))
                        .frame(height: 1)
                }

                ForEach(0..<Self.slots.count, id: \.self) { row in
                    dotMatrixRow(row: row)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .strokeBorder(Color(hex: "1a1a1a"), lineWidth: 2)
        }
        .shadow(color: Color(hex: "005000").opacity(0.15), radius: 10)
    }

    private func dotMatrixRow(row: Int) -> some View {
        let slot = Self.slots[row]
        let isActive = row == activeSlotIndex
        let value = slot.options[slotValueIndices[row]]

        let labelColor = isActive ? Color(hex: "4aff4a") : Color(hex: "2a7a2a")
        let valueColor = isActive ? Color(hex: "7fff7f") : Color(hex: "5adf5a")
        let glowRadius: CGFloat = isActive ? 6 : 3

        return HStack(spacing: 4) {
            Text(slot.label)
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundStyle(labelColor)
                .frame(width: 28, alignment: .leading)

            Text(":")
                .font(.system(size: 8, weight: .regular, design: .monospaced))
                .foregroundStyle(Color(hex: "1a4a1a"))

            Text(value)
                .font(.system(size: isActive && row == 0 ? 13 : 11, weight: .regular, design: .monospaced))
                .foregroundStyle(valueColor)
                .shadow(color: Color(hex: "00cc00").opacity(isActive ? 0.7 : 0.4), radius: glowRadius)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
        .padding(.horizontal, isActive ? 6 : 0)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color(hex: "0a200a").opacity(0.55))
            }
        }
    }

    // MARK: - Wheel mount + black clickwheel

    private func wheelMountSection(diameter: CGFloat) -> some View {
        let mountPad: CGFloat = 9
        let outerD = diameter + mountPad * 2

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "c0c0c0"),
                            Color(hex: "ababab"),
                            Color(hex: "9e9e9e"),
                            Color(hex: "b0b0b0")
                        ],
                        center: UnitPoint(x: 0.48, y: 0.44),
                        startRadius: 0,
                        endRadius: outerD / 2
                    )
                )
                .frame(width: outerD, height: outerD)
                .shadow(color: .black.opacity(0.42), radius: 7, y: 4)
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.black.opacity(0.22)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }

            blackClickwheel(diameter: diameter)
        }
        .frame(width: outerD, height: outerD)
    }

    private func blackClickwheel(diameter: CGFloat) -> some View {
        let outerR = diameter / 2 - 2
        let innerR = diameter * 0.46 / 2
        let centerD = diameter * 0.3 * 2

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "5a5a5a"), Color(hex: "3a3a3a"), Color(hex: "242424")],
                        center: UnitPoint(x: 0.42, y: 0.38),
                        startRadius: 0,
                        endRadius: outerR
                    )
                )
                .frame(width: diameter, height: diameter)
                .shadow(color: .black.opacity(0.55), radius: 5, y: 3)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        .padding(2)
                }

            blackWheelNotches(diameter: diameter)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "404040"), Color(hex: "2e2e2e"), Color(hex: "222222")],
                        center: UnitPoint(x: 0.44, y: 0.40),
                        startRadius: 0,
                        endRadius: innerR
                    )
                )
                .frame(width: innerR * 2, height: innerR * 2)
                .overlay {
                    Ellipse()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: innerR * 1.1, height: innerR * 0.36)
                        .offset(x: -innerR * 0.15, y: -innerR * 0.2)
                }
                .allowsHitTesting(false)

            Circle()
                .fill(Color.orange.opacity(0.001))
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
                .gesture(wheelDragGesture(diameter: diameter))

            Button {
                okPressed = true
                emitGesture("decide")
                let summary = currentCombinationText()
                statusLine = "確定: \(summary)"
                Self.log.info("decide \(summary, privacy: .public)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    okPressed = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: okPressed
                                    ? [Color(hex: "282828"), Color(hex: "303030")]
                                    : [Color(hex: "606060"), Color(hex: "4c4c4c"), Color(hex: "3a3a3a")],
                                center: UnitPoint(x: okPressed ? 0.5 : 0.42, y: okPressed ? 0.58 : 0.36),
                                startRadius: 0,
                                endRadius: centerD / 2
                            )
                        )
                        .overlay {
                            Circle()
                                .strokeBorder(Color(hex: "141414").opacity(0.6), lineWidth: 1)
                        }
                        .shadow(
                            color: .black.opacity(okPressed ? 0.7 : 0.5),
                            radius: okPressed ? 2 : 4,
                            y: okPressed ? 1 : 3
                        )

                    Text("OK")
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .tracking(1.2)
                        .foregroundStyle(
                            okPressed
                                ? Color(hex: "8c8c82").opacity(0.7)
                                : Color(hex: "c3beb4").opacity(0.8)
                        )
                }
                .frame(width: centerD, height: centerD)
            }
            .buttonStyle(WheelCenterPushStyle())
        }
        .frame(width: diameter, height: diameter)
    }

    private func blackWheelNotches(diameter: CGFloat) -> some View {
        let outerR = diameter / 2 - 6
        let notchR = outerR - 4

        return ZStack {
            ForEach(0..<Self.wheelNotchCount, id: \.self) { i in
                let isAccent = i % 8 == 0
                let w = isAccent ? 2.0 : 1.5
                let h = isAccent ? 8.0 : 6.0
                RoundedRectangle(cornerRadius: 0.8, style: .continuous)
                    .fill(
                        isAccent
                            ? Color(hex: "c8c3b9").opacity(0.38)
                            : Color(hex: "a5a096").opacity(0.22)
                    )
                    .frame(width: w, height: h)
                    .offset(y: -notchR)
                    .rotationEffect(.degrees(Double(i) / Double(Self.wheelNotchCount) * 360))
            }
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }

    private func wheelDragGesture(diameter: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                isWheelInteractActive = true
                let center = CGPoint(x: diameter / 2, y: diameter / 2)
                let angleRad = atan2(value.location.y - center.y, value.location.x - center.x)
                let angleDeg = angleRad * 180 / .pi

                if let previous = lastTouchAngleDegrees {
                    var delta = angleDeg - previous
                    if delta > 180 { delta -= 360 }
                    if delta < -180 { delta += 360 }

                    let now = Date()
                    if let prior = lastSampleDate {
                        let dt = now.timeIntervalSince(prior)
                        if dt > 0.001 { angularVelocityDegPerSec = delta / dt }
                    }
                    lastSampleDate = now
                    applyWheelDelta(delta)
                } else {
                    lastSampleDate = Date()
                }
                lastTouchAngleDegrees = angleDeg
            }
            .onEnded { _ in
                lastTouchAngleDegrees = nil
                lastSampleDate = nil
                isWheelInteractActive = false
                applyWeakInertia()
                angularVelocityDegPerSec = 0
            }
    }

    private func applyWheelDelta(_ delta: Double) {
        notchAccumulator += delta
        while notchAccumulator >= Self.notchAngle {
            notchAccumulator -= Self.notchAngle
            stepActiveSlotValue(direction: 1)
        }
        while notchAccumulator <= -Self.notchAngle {
            notchAccumulator += Self.notchAngle
            stepActiveSlotValue(direction: -1)
        }
    }

    private func applyWeakInertia() {
        let magnitude = abs(angularVelocityDegPerSec)
        guard magnitude > Self.notchAngle * (4.0 / 3.0) else { return }
        var extra = angularVelocityDegPerSec * 0.05
        let cap = Self.notchAngle * 0.75
        extra = min(max(extra, -cap), cap)
        applyWheelDelta(extra)
    }

    private func stepActiveSlotValue(direction: Int) {
        let slot = Self.slots[activeSlotIndex]
        let count = slot.options.count
        guard count > 0 else { return }
        var idx = slotValueIndices[activeSlotIndex]
        idx = (idx + direction + count) % count
        slotValueIndices[activeSlotIndex] = idx
        emitGesture("wheel")
    }

    // MARK: - Bottom buttons (非表示・将来用に保持)

    private func bottomButtons(width w: CGFloat) -> some View {
        HStack(spacing: w * 0.04) {
            resinKey(title: "MENU", monospace: true, width: w * 0.28) {
                activeSlotIndex = (activeSlotIndex + 1) % Self.slots.count
                emitGesture("menu")
            }
            resinKey(title: "選択", monospace: false, width: w * 0.28) {
                emitGesture("select")
                statusLine = "選択: \(currentCombinationText())"
            }
            resinKey(title: "生成 →", monospace: false, width: w * 0.34) {
                emitGesture("generate")
                statusLine = "生成 → \(currentCombinationText())"
            }
        }
    }

    private func resinKey(title: String, monospace: Bool, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(monospace
                    ? .system(size: 10, weight: .medium, design: .monospaced)
                    : .system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hex: "787470"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background {
                    LinearGradient(
                        colors: [Color(hex: "ece8e0"), Color(hex: "d8d4cc")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color(hex: "c4c0b8"), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
        }
        .buttonStyle(ResinKeyStyle())
        .frame(width: width)
    }

    // MARK: - Helpers

    private func currentCombinationText() -> String {
        Self.slots.indices.map { i in
            "\(Self.slots[i].label)=\(Self.slots[i].options[slotValueIndices[i]])"
        }.joined(separator: " ")
    }

    private func emitGesture(_ name: String) {
        lastGesture = name
        Self.log.info("lastGesture=\(name, privacy: .public)")
    }

    #if DEBUG
    private var debugHUD: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("lastGesture=\(lastGesture)")
            if !statusLine.isEmpty {
                Text(statusLine)
                    .lineLimit(2)
            }
        }
        .font(.system(size: 9, design: .monospaced))
        .foregroundStyle(Color(hex: "4aff4a").opacity(0.85))
        .padding(6)
        .background(Color.black.opacity(0.55))
        .cornerRadius(4)
    }
    #endif
}

// MARK: - Decorative overlays

private struct BrushedMetalGrain: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 2)
                context.fill(
                    Path(rect),
                    with: .color(Color.white.opacity(0.038))
                )
                y += 4
            }
        }
    }
}

private struct ScanlineOverlay: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                let rect = CGRect(x: 0, y: y, width: size.width, height: 2)
                context.fill(
                    Path(rect),
                    with: .color(Color.black.opacity(0.18))
                )
                y += 4
            }
        }
    }
}

// MARK: - Button styles

private struct ResinKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 1 : 0)
            .shadow(
                color: Color(hex: "b0aca4").opacity(configuration.isPressed ? 0.15 : 0.5),
                radius: 0,
                y: configuration.isPressed ? 0 : 2
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

private struct WheelCenterPushStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview {
    MemoryTunerView()
}
#endif
