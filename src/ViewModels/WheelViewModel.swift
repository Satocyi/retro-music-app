import Combine
import Foundation

// チューニング用定数。実機確認後に調整する。ここ以外に角度の数値を書かない。
private let notchAngle: Double = 30.0 // degrees

/// ホイールの回転・選択状態（ScrollView / List は使わない）
final class WheelViewModel: ObservableObject {
    @Published var cards: [MemoryCard]
    @Published var selectedIndex: Int
    @Published var wheelAngle: Double

    /// 中央ボタン確定のUI向け通知（printに加えてUIで見えるようにする）
    @Published var lastCenterTapDescription: String = ""

    private var notchAccumulator: Double = 0

    init(cards: [MemoryCard] = MemoryCard.mockCards) {
        self.cards = cards
        self.selectedIndex = 0
        self.wheelAngle = 0
    }

    var currentCard: MemoryCard {
        cards[selectedIndex]
    }

    /// ホイール回転時に呼ばれる。`delta` は度（degree）。
    func onWheelRotated(delta: Double) {
        wheelAngle += delta
        let n = cards.count
        guard n > 0 else { return }

        notchAccumulator += delta

        while notchAccumulator >= notchAngle {
            notchAccumulator -= notchAngle
            selectedIndex = (selectedIndex + 1) % n
        }

        while notchAccumulator <= -notchAngle {
            notchAccumulator += notchAngle
            selectedIndex = (selectedIndex - 1 + n) % n
        }
    }

    /// ドラッグ終了時の弱い慣性。ノッチ角の分数のみでスケールし、ここに新たな角度定数は置かない。
    func applyWeakInertia(angularVelocityDegreesPerSecond: Double) {
        let magnitude = abs(angularVelocityDegreesPerSecond)
        // 体感しきい値（回転開始のトリガのみ。角度値は notchAngle の倍数のみ使う）
        guard magnitude > notchAngle * (4.0 / 3.0) else { return }

        let scale = 0.05
        var extra = angularVelocityDegreesPerSecond * scale
        let cap = notchAngle * 0.75
        if extra > cap { extra = cap }
        if extra < -cap { extra = -cap }

        onWheelRotated(delta: extra)
    }

    func onCenterTapped() {
        guard cards.indices.contains(selectedIndex) else { return }
        let card = currentCard
        lastCenterTapDescription =
            "確定: \(card.line1) / \(card.line2) / \(card.line3)"
        print("Selected: \(card.line1) / \(card.line2) / \(card.line3)")
    }
}
