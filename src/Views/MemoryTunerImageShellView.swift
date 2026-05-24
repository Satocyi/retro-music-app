import OSLog
import SwiftUI

/// 参照PNG一枚＋正規化ヒット領域のみの MVP シェル（`WheelViewModel` 非結線）
struct MemoryTunerImageShellView: View {
    private static let log = Logger(subsystem: "dev.wheelprototype.app", category: "MemoryTunerShell")

#if DEBUG
    /// ヒット領域の可視化。位置確認が終わったら `false` に戻す。
    private let showDebugHitAreas = true

    @State private var lastGesture: String = "none"
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

    private static let wheelDragMinimumDistance: CGFloat = 8
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
            Text("lastGesture=\(lastGesture)")
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
                wheelDiskLayer(width: w, height: h, minSide: minSide)
                    .zIndex(0)

                normalizedButtonLayer(Self.menuHit, width: w, height: h, gestureLabel: "menu")
                    .zIndex(1)
                normalizedButtonLayer(Self.selectHit, width: w, height: h, gestureLabel: "select")
                    .zIndex(1)
                normalizedButtonLayer(Self.generateHit, width: w, height: h, gestureLabel: "generate")
                    .zIndex(1)
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
        .allowsHitTesting(true)
    }

    private func normalizedButtonLayer(_ rect: NormalizedHitRect, width w: CGFloat, height h: CGFloat, gestureLabel: String) -> some View {
        let rectWidth = rect.size.width * w
        let rectHeight = rect.size.height * h

        return Rectangle()
            .fill(debugButtonTint(for: gestureLabel))
            .frame(width: rectWidth, height: rectHeight)
            .offset(x: rect.origin.x * w, y: rect.origin.y * h)
            .contentShape(Rectangle())
            .onTapGesture {
                recordGesture(gestureLabel)
            }
            .allowsHitTesting(true)
    }

    private func wheelDiskLayer(width w: CGFloat, height h: CGFloat, minSide: CGFloat) -> some View {
        let diameter = Self.wheelDiameterOnMinSide * minSide
        let cx = Self.wheelNormalizedCenter.x * w
        let cy = Self.wheelNormalizedCenter.y * h

        return Circle()
            .fill(debugWheelTint())
            .frame(width: diameter, height: diameter)
            .offset(x: cx - diameter / 2, y: cy - diameter / 2)
            .contentShape(Circle())
            .onTapGesture {
                emitWheelDebounced()
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: Self.wheelDragMinimumDistance)
                    .onChanged { _ in
                        emitWheelDebounced()
                    }
            )
            .allowsHitTesting(true)
    }

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
#endif
    }

#if DEBUG
    private func debugButtonTint(for label: String) -> Color {
        guard showDebugHitAreas else { return .clear }
        switch label {
        case "menu": return Color.blue.opacity(0.2)
        case "select": return Color.green.opacity(0.2)
        case "generate": return Color.orange.opacity(0.2)
        default: return .clear
        }
    }

    private func debugWheelTint() -> Color {
        guard showDebugHitAreas else { return .clear }
        return Color.purple.opacity(0.2)
    }
#else
    private func debugButtonTint(for _: String) -> Color { .clear }

    private func debugWheelTint() -> Color { .clear }
#endif
}
