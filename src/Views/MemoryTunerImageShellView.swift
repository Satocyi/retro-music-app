import OSLog
import SwiftUI

/// 参照PNG一枚＋DEBUG可視ボタンによる MVP シェル（`WheelViewModel` 非結線）
struct MemoryTunerImageShellView: View {
    private static let log = Logger(subsystem: "dev.wheelprototype.app", category: "MemoryTunerShell")

#if DEBUG
    /// 操作領域の可視化。反応確認が終わるまで `true` のままにする。
    private let showDebugHitAreas = true

    @State private var lastGesture: String = "none"
    @State private var gestureCount: Int = 0
#endif

    /// `deviceImage` 表示矩形を 1×1 としたときの相対矩形（左上原点）
    private struct NormalizedHitRect {
        var origin: CGPoint
        var size: CGSize
    }

    /// 初期係数（reference_memory_tuner_original.png 524×915 から計測・微調整前提）
    private static let menuHit = NormalizedHitRect(origin: CGPoint(x: 0.105, y: 0.795), size: CGSize(width: 0.244, height: 0.074))
    private static let selectHit = NormalizedHitRect(origin: CGPoint(x: 0.368, y: 0.795), size: CGSize(width: 0.237, height: 0.074))
    private static let generateHit = NormalizedHitRect(origin: CGPoint(x: 0.624, y: 0.795), size: CGSize(width: 0.172, height: 0.074))

    /// ホイール近似円（中心と直径は「短辺」基準）
    private static let wheelNormalizedCenter = CGPoint(x: 0.475, y: 0.620)
    private static let wheelDiameterOnMinSide: CGFloat = 0.52

    private static let wheelDebounceSeconds: TimeInterval = 0.15

    /// セーフエリア外調整はここだけ触る（仕様 §5）
    private let layoutSafeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

    @State private var lastWheelEmitAt: Date = .distantPast

    var body: some View {
        ZStack {
            Color(hex: "111113").ignoresSafeArea()
            Image("memory_tuner_device_ref")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(layoutSafeInsets)
                .allowsHitTesting(false)
                .overlay(alignment: .topLeading) {
                    interactionLayer
                }
#if DEBUG
            debugGestureHUD
#endif
        }
    }

#if DEBUG
    private var debugGestureHUD: some View {
        VStack {
            Spacer()
            Text("lastGesture=\(lastGesture) (#\(gestureCount))")
                .font(.footnote.monospaced())
                .foregroundStyle(.yellow.opacity(0.95))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.bottom, 8)
        }
        .allowsHitTesting(false)
    }
#endif

    private var interactionLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minSide = min(w, h)

            ZStack(alignment: .topLeading) {
                wheelDiskButton(width: w, height: h, minSide: minSide)
                    .zIndex(0)

                debugRectButton(
                    label: "MENU",
                    gestureLabel: "menu",
                    tint: .blue,
                    rect: Self.menuHit,
                    width: w,
                    height: h
                )
                .zIndex(1)

                debugRectButton(
                    label: "選択",
                    gestureLabel: "select",
                    tint: .green,
                    rect: Self.selectHit,
                    width: w,
                    height: h
                )
                .zIndex(1)

                debugRectButton(
                    label: "生成",
                    gestureLabel: "generate",
                    tint: .orange,
                    rect: Self.generateHit,
                    width: w,
                    height: h
                )
                .zIndex(1)
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
        .allowsHitTesting(true)
    }

#if DEBUG
    private func debugRectButton(
        label: String,
        gestureLabel: String,
        tint: Color,
        rect: NormalizedHitRect,
        width w: CGFloat,
        height h: CGFloat
    ) -> some View {
        let rectWidth = rect.size.width * w
        let rectHeight = rect.size.height * h
        let fillOpacity: CGFloat = showDebugHitAreas ? 0.45 : 0.35
        let strokeOpacity: CGFloat = showDebugHitAreas ? 0.95 : 0.75
        let strokeWidth: CGFloat = showDebugHitAreas ? 2.5 : 2

        return Button {
            recordGesture(gestureLabel)
        } label: {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(tint.opacity(fillOpacity))
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(tint.opacity(strokeOpacity), lineWidth: strokeWidth)
                }
                .overlay {
                    Text(label)
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 1, y: 1)
                }
                .frame(width: rectWidth, height: rectHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .offset(x: rect.origin.x * w, y: rect.origin.y * h)
    }

    private func wheelDiskButton(width w: CGFloat, height h: CGFloat, minSide: CGFloat) -> some View {
        let diameter = Self.wheelDiameterOnMinSide * minSide
        let cx = Self.wheelNormalizedCenter.x * w
        let cy = Self.wheelNormalizedCenter.y * h
        let fillOpacity: CGFloat = showDebugHitAreas ? 0.40 : 0.30
        let strokeOpacity: CGFloat = showDebugHitAreas ? 0.95 : 0.75
        let strokeWidth: CGFloat = showDebugHitAreas ? 2.5 : 2

        return Button {
            emitWheelDebounced()
        } label: {
            Circle()
                .fill(Color.purple.opacity(fillOpacity))
                .overlay {
                    Circle()
                        .strokeBorder(Color.purple.opacity(strokeOpacity), lineWidth: strokeWidth)
                }
                .overlay {
                    Text("WHEEL")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 1, y: 1)
                }
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .offset(x: cx - diameter / 2, y: cy - diameter / 2)
    }
#else
    private func debugRectButton(
        label _: String,
        gestureLabel: String,
        tint _: Color,
        rect: NormalizedHitRect,
        width w: CGFloat,
        height h: CGFloat
    ) -> some View {
        let rectWidth = rect.size.width * w
        let rectHeight = rect.size.height * h

        return Button {
            recordGesture(gestureLabel)
        } label: {
            Color.clear
                .frame(width: rectWidth, height: rectHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .offset(x: rect.origin.x * w, y: rect.origin.y * h)
    }

    private func wheelDiskButton(width w: CGFloat, height h: CGFloat, minSide: CGFloat) -> some View {
        let diameter = Self.wheelDiameterOnMinSide * minSide
        let cx = Self.wheelNormalizedCenter.x * w
        let cy = Self.wheelNormalizedCenter.y * h

        return Button {
            emitWheelDebounced()
        } label: {
            Color.clear
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .offset(x: cx - diameter / 2, y: cy - diameter / 2)
    }
#endif

    private func emitWheelDebounced() {
        let now = Date()
        guard now.timeIntervalSince(lastWheelEmitAt) >= Self.wheelDebounceSeconds else { return }
        lastWheelEmitAt = now
        recordGesture("wheel")
    }

    private func recordGesture(_ name: String) {
        Self.log.info("lastGesture=\(name, privacy: .public)")
        print("lastGesture=\(name)")
#if DEBUG
        lastGesture = name
        gestureCount += 1
#endif
    }
}
