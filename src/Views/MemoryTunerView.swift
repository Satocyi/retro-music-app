import OSLog
import SwiftUI

/// Memory Tuner — 初期iPod風・白樹脂筐体（v1 見た目リデザイン）
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

    @State private var activeSlotIndex = 0
    @State private var slotValueIndices: [Int]
    @State private var lastGesture = "none"
    @State private var statusLine = ""

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
            let lcdH = lcdW * 0.38
            let wheelGap: CGFloat = 10
            let wheelTail: CGFloat = 2
            let railBottom = min(max(geo.size.height * (18.95 / 100), 134), 148)

            let wheelCapV = innerClear - lcdH - wheelGap - wheelTail - railBottom
            let wheelCapH = geo.size.width - 8
            let wheelFlat = min(wheelCapH, wheelCapV)

            let slackBelow = innerClear - lcdH - wheelGap - wheelTail - wheelFlat

            let stretchCap = min(max(geo.size.height * (17.95 / 100), 108), 148)
            let stretchY = min(max(slackBelow - railBottom, 0), stretchCap)
            let bottomTail = slackBelow - stretchY

            let wheelStretchScale = (wheelFlat + stretchY) / wheelFlat

            ZStack(alignment: .topLeading) {
                resinChassisBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    lcdPanel(width: geo.size.width - 56)
                        .padding(.top, geo.safeAreaInsets.top + 20)
                        .padding(.horizontal, 28)

                    Color.clear
                        .frame(height: wheelGap)
                        .frame(maxWidth: .infinity)

                    wheelSection(diameter: wheelFlat)
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

    // MARK: - Chassis

    private var resinChassisBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "f2efe8"),
                    Color(hex: "e8e4dc"),
                    Color(hex: "ece8e0")
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.45))
                    .frame(height: 1)
                    .padding(.top, 1)
                Spacer()
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - LCD (5 slots)

    private func lcdPanel(width lcdW: CGFloat) -> some View {
        ZStack {
            Color(hex: "080a08")

            VStack(spacing: 0) {
                ForEach(0..<Self.slots.count, id: \.self) { row in
                    lcdRow(row: row, width: lcdW)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .frame(width: lcdW, height: lcdW * 0.38)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func lcdRow(row: Int, width lcdW: CGFloat) -> some View {
        let slot = Self.slots[row]
        let isActive = row == activeSlotIndex
        let value = slot.options[slotValueIndices[row]]

        return HStack(spacing: 0) {
            Text(slot.label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(isActive ? Color(hex: "5a7458") : Color(hex: "2e3a2c"))
                .frame(width: lcdW * 0.2, alignment: .leading)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(isActive ? Color(hex: "7a9a6e") : Color(hex: "2e3a2c"))
        }
        .padding(.horizontal, isActive ? 10 : 8)
        .padding(.vertical, 9)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(hex: "141a14").opacity(0.55))
            }
        }
    }

    // MARK: - Wheel

    private func wheelSection(diameter: CGFloat) -> some View {
        let ringW = diameter * 0.16
        let innerD = diameter - 2 * ringW
        let centerD = max(54, innerD - diameter * 0.24)

        return ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color(hex: "e4e0d8"),
                            Color(hex: "f0ece4"),
                            Color(hex: "dcd8d0"),
                            Color(hex: "ece8e0"),
                            Color(hex: "d8d4cc"),
                            Color(hex: "e4e0d8")
                        ],
                        center: .center
                    )
                )
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle()
                        .strokeBorder(Color(hex: "b8b4ac"), lineWidth: 1)
                }

            Circle()
                .strokeBorder(Color(hex: "2a2a28").opacity(0.35), lineWidth: ringW * 0.55)
                .frame(width: diameter - ringW * 0.9, height: diameter - ringW * 0.9)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(hex: "ece8e0"))
                .frame(width: innerD, height: innerD)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

            wheelNotches(diameter: diameter)

            directionalArrows(diameter: diameter, ringWidth: ringW, active: isWheelInteractActive)

            Circle()
                .fill(Color.orange.opacity(0.001))
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
                .gesture(wheelDragGesture(diameter: diameter))

            Button {
                emitGesture("decide")
                let summary = currentCombinationText()
                statusLine = "確定: \(summary)"
                Self.log.info("decide \(summary, privacy: .public)")
            } label: {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f4f0e8"), Color(hex: "dcd8d0")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(Circle().strokeBorder(Color(hex: "c0bcb4"), lineWidth: 1))
                    .frame(width: centerD, height: centerD)
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            }
            .buttonStyle(WheelCenterPushStyle())
        }
        .frame(width: diameter, height: diameter)
    }

    private func wheelNotches(diameter: CGFloat) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let major = i % 3 == 0
                let h = major ? CGFloat(6) : CGFloat(4)
                RoundedRectangle(cornerRadius: 0.5, style: .continuous)
                    .fill(Color(hex: "a8a49c"))
                    .frame(width: 1.5, height: h)
                    .offset(y: -diameter / 2 + h / 2 + 4)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }

    private func directionalArrows(diameter: CGFloat, ringWidth: CGFloat, active: Bool) -> some View {
        let inset = ringWidth / 2 + 5
        let opacity = active ? 0.42 : 0.22
        return ZStack {
            smallArrow().offset(y: -diameter / 2 + inset)
            smallArrow().rotationEffect(.degrees(180)).offset(y: diameter / 2 - inset)
            smallArrow().rotationEffect(.degrees(-90)).offset(x: -diameter / 2 + inset)
            smallArrow().rotationEffect(.degrees(90)).offset(x: diameter / 2 - inset)
        }
        .foregroundStyle(Color(hex: "888480").opacity(opacity))
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }

    private func smallArrow() -> some View {
        Path { path in
            path.move(to: CGPoint(x: 3.5, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 6))
            path.addLine(to: CGPoint(x: 7, y: 6))
            path.closeSubpath()
        }
        .frame(width: 7, height: 6)
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

    // MARK: - Bottom buttons

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
        .foregroundStyle(Color(hex: "7a9a6e").opacity(0.85))
        .padding(6)
        .background(Color.black.opacity(0.55))
        .cornerRadius(4)
    }
    #endif
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
