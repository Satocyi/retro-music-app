import OSLog
import SwiftUI

/// 参照PNGをデザイン正本とした SwiftUI 構成 UI（v0）
/// 見た目: `_design/previews/assets/reference_memory_tuner_original.png`
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
            let chassisW = min(geo.size.width - 32, 340)

            ZStack(alignment: .topLeading) {
                Color(hex: "111113").ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    deviceBody(width: chassisW)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                #if DEBUG
                debugHUD
                    .padding(.top, geo.safeAreaInsets.top + 6)
                    .padding(.leading, 10)
                #endif
            }
        }
    }

    // MARK: - Device body

    private func deviceBody(width w: CGFloat) -> some View {
        VStack(spacing: w * 0.028) {
            headerBar
                .padding(.horizontal, w * 0.07)

            lcdPanel(width: w * 0.86)
                .padding(.horizontal, w * 0.07)

            wheelSection(diameter: w * 0.72)
                .padding(.top, w * 0.01)

            bottomButtons(width: w * 0.86)
                .padding(.horizontal, w * 0.07)

            Text("MEM-02 · ウォームテクニウム")
                .font(.system(size: 7, design: .monospaced))
                .foregroundStyle(Color(hex: "888880"))
                .padding(.top, 2)
        }
        .padding(.vertical, w * 0.055)
        .frame(width: w)
        .background { brushedMetalChassis(cornerRadius: w * 0.038) }
        .overlay {
            RoundedRectangle(cornerRadius: w * 0.038, style: .continuous)
                .strokeBorder(Color(hex: "787878"), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.45), radius: 18, y: 10)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Text("MEMORY TUNER")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .tracking(2.5)
                .foregroundStyle(Color(hex: "707068"))
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(hex: "4e8a4e"))
                    .frame(width: 6, height: 6)
                    .shadow(color: Color(hex: "4e8a4e").opacity(0.55), radius: 3)
                Text("STANDBY")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hex: "909088"))
            }
        }
    }

    // MARK: - LCD (5 slots)

    private func lcdPanel(width lcdW: CGFloat) -> some View {
        ZStack {
            Color(hex: "091209")

            Canvas { context, size in
                var y: CGFloat = 0
                while y <= size.height {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                    context.fill(Path(rect), with: .color(Color.black.opacity(0.35)))
                    y += 3
                }
            }
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                ForEach(0..<Self.slots.count, id: \.self) { row in
                    lcdRow(row: row, width: lcdW)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .frame(width: lcdW, height: lcdW * 0.52)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Color(hex: "1a1e1a"), lineWidth: 1)
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(Color(hex: "050805"))
                    .frame(height: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .allowsHitTesting(false)
        }
    }

    private func lcdRow(row: Int, width lcdW: CGFloat) -> some View {
        let slot = Self.slots[row]
        let isActive = row == activeSlotIndex
        let value = slot.options[slotValueIndices[row]]

        return HStack(spacing: 0) {
            Text(slot.label)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(isActive ? Color(hex: "4a6848") : Color(hex: "2a3828"))
                .frame(width: lcdW * 0.18, alignment: .leading)

            Spacer(minLength: 4)

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(isActive ? Color(hex: "8ec85a") : Color(hex: "2a3828"))
                .shadow(color: isActive ? Color(hex: "6ea046").opacity(0.35) : .clear, radius: 3)

            if isActive {
                RoundedRectangle(cornerRadius: 0.5, style: .continuous)
                    .fill(Color(hex: "6ea046"))
                    .frame(width: 3, height: 16)
                    .padding(.leading, 6)
            }
        }
        .padding(.horizontal, isActive ? 8 : 6)
        .padding(.vertical, 7)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .strokeBorder(Color(hex: "5a9848"), lineWidth: 1)
                    .background(Color(hex: "0b140a").cornerRadius(2))
            }
        }
    }

    // MARK: - Wheel

    private func wheelSection(diameter: CGFloat) -> some View {
        let ringW = diameter * 0.17
        let innerD = diameter - 2 * ringW
        let centerD = max(52, innerD - diameter * 0.22)

        return ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color(hex: "b8b4ac"),
                            Color(hex: "d0ccc4"),
                            Color(hex: "a8a4a0"),
                            Color(hex: "c8c4bc"),
                            Color(hex: "b0aca4"),
                            Color(hex: "b8b4ac")
                        ],
                        center: .center
                    )
                )
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle()
                        .strokeBorder(Color(hex: "888480"), lineWidth: 1)
                }

            Circle()
                .fill(Color(hex: "131514"))
                .frame(width: innerD, height: innerD)
                .shadow(color: .black.opacity(0.85), radius: 8, y: 6)

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
                Text("決定")
                    .font(.system(size: 7, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "707068"))
                    .frame(width: centerD, height: centerD)
                    .background {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "c8c4bc"), Color(hex: "a8a4a0")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(Circle().strokeBorder(Color(hex: "888480"), lineWidth: 1))
                    }
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            }
            .buttonStyle(WheelCenterPushStyle())
        }
        .frame(width: diameter, height: diameter)
    }

    private func wheelNotches(diameter: CGFloat) -> some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let major = i % 3 == 0
                let h = major ? CGFloat(7) : CGFloat(5)
                RoundedRectangle(cornerRadius: 0.5, style: .continuous)
                    .fill(Color(hex: "909088"))
                    .frame(width: 1.5, height: h)
                    .offset(y: -diameter / 2 + h / 2 + 3)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }

    private func directionalArrows(diameter: CGFloat, ringWidth: CGFloat, active: Bool) -> some View {
        let inset = ringWidth / 2 + 4
        let opacity = active ? 0.5 : 0.28
        return ZStack {
            smallArrow().offset(y: -diameter / 2 + inset)
            smallArrow().rotationEffect(.degrees(180)).offset(y: diameter / 2 - inset)
            smallArrow().rotationEffect(.degrees(-90)).offset(x: -diameter / 2 + inset)
            smallArrow().rotationEffect(.degrees(90)).offset(x: diameter / 2 - inset)
        }
        .foregroundStyle(Color(hex: "989490").opacity(opacity))
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
        HStack(spacing: w * 0.028) {
            metalKey(title: "MENU", monospace: true, width: w * 0.28) {
                activeSlotIndex = (activeSlotIndex + 1) % Self.slots.count
                emitGesture("menu")
            }
            metalKey(title: "選択", monospace: false, width: w * 0.28) {
                emitGesture("select")
                statusLine = "選択: \(currentCombinationText())"
            }
            metalKey(title: "生成 →", monospace: false, width: w * 0.34) {
                emitGesture("generate")
                statusLine = "生成 → \(currentCombinationText())"
            }
        }
    }

    private func metalKey(title: String, monospace: Bool, width: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(monospace
                    ? .system(size: 10, weight: .medium, design: .monospaced)
                    : .system(size: 10, weight: .medium))
                .foregroundStyle(Color(hex: "606058"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    LinearGradient(
                        colors: [Color(hex: "c4c0b8"), Color(hex: "a8a4a0")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color(hex: "888480"), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
        }
        .buttonStyle(MetalKeyStyle())
        .frame(width: width)
    }

    // MARK: - Chassis texture

    private func brushedMetalChassis(cornerRadius: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "c0bcb4"), Color(hex: "a8a4a0"), Color(hex: "b4b0a8")],
                startPoint: .top,
                endPoint: .bottom
            )

            Canvas { context, size in
                var x: CGFloat = 0
                while x <= size.width {
                    let rect = CGRect(x: x, y: 0, width: 1, height: size.height)
                    let shade = (Int(x) % 4 == 0) ? 0.08 : 0.04
                    context.fill(Path(rect), with: .color(Color.white.opacity(shade)))
                    x += 2.5
                }
            }
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
        .foregroundStyle(Color(hex: "8ec85a").opacity(0.85))
        .padding(6)
        .background(Color.black.opacity(0.55))
        .cornerRadius(4)
    }
    #endif
}

// MARK: - Button styles

private struct MetalKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? 1 : 0)
            .shadow(
                color: Color(hex: "686460").opacity(configuration.isPressed ? 0.2 : 0.7),
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
