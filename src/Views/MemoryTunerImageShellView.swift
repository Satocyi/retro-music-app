import OSLog
import SwiftUI

/// 参照PNG一枚＋正規化ヒット領域のみの MVP シェル（`WheelViewModel` 非結線）
struct MemoryTunerImageShellView: View {
    private static let log = Logger(subsystem: "dev.wheelprototype.app", category: "MemoryTunerShell")

    /// `deviceImage` 表示矩形を 1×1 としたときの相対矩形（左上原点）
    private struct NormalizedHitRect {
        var origin: CGPoint
        var size: CGSize
    }

    /// 初期係数（実機で微調整する前提のひな型）
    private static let menuHit = NormalizedHitRect(origin: CGPoint(x: 0.04, y: 0.875), size: CGSize(width: 0.22, height: 0.09))
    private static let selectHit = NormalizedHitRect(origin: CGPoint(x: 0.34, y: 0.875), size: CGSize(width: 0.32, height: 0.09))
    private static let generateHit = NormalizedHitRect(origin: CGPoint(x: 0.68, y: 0.875), size: CGSize(width: 0.28, height: 0.09))

    /// ホイール近似円（中心と直径は「短辺」基準）
    private static let wheelNormalizedCenter = CGPoint(x: 0.5, y: 0.62)
    private static let wheelDiameterOnMinSide: CGFloat = 0.72

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
                .overlay { interactionLayer }
        }
    }

    @ViewBuilder
    private var interactionLayer: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let minSide = min(w, h)

            ZStack(alignment: .topLeading) {
                wheelDiskLayer(width: w, height: h, minSide: minSide)
                normalizedButtonLayer(Self.menuHit, width: w, height: h, gestureLabel: "menu")
                normalizedButtonLayer(Self.selectHit, width: w, height: h, gestureLabel: "select")
                normalizedButtonLayer(Self.generateHit, width: w, height: h, gestureLabel: "generate")
            }
        }
        .allowsHitTesting(true)
    }

    private func normalizedButtonLayer(_ rect: NormalizedHitRect, width w: CGFloat, height h: CGFloat, gestureLabel: String) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(width: rect.size.width * w, height: rect.size.height * h)
            .offset(x: rect.origin.x * w, y: rect.origin.y * h)
            .onTapGesture {
                Self.logGesture(gestureLabel)
            }
    }

    private func wheelDiskLayer(width w: CGFloat, height h: CGFloat, minSide: CGFloat) -> some View {
        let diameter = Self.wheelDiameterOnMinSide * minSide
        let cx = Self.wheelNormalizedCenter.x * w
        let cy = Self.wheelNormalizedCenter.y * h

        return Color.clear
            .contentShape(Circle())
            .frame(width: diameter, height: diameter)
            .position(x: cx, y: cy)
            .gesture(
                DragGesture(minimumDistance: Self.wheelDragMinimumDistance)
                    .onChanged { _ in
                        emitWheelDebounced()
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        emitWheelDebounced()
                    }
            )
    }

    private func emitWheelDebounced() {
        let now = Date()
        guard now.timeIntervalSince(lastWheelEmitAt) >= Self.wheelDebounceSeconds else { return }
        lastWheelEmitAt = now
        Self.logGesture("wheel")
    }

    private static func logGesture(_ name: String) {
        log.info("lastGesture=\(name, privacy: .public)")
    }
}
