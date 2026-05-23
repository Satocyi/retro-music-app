# Cursor向け実装指示書 — MemoryCard表示・ループ実装 v0

**対象フェーズ**: Phase 3 プロトタイプ実装（3番目のステップ）  
**作成者**: Claude  
**作成日**: 2026-05-23  
**前提コミット**: fa8c331  
**前提ドキュメント**: `_specs/memory_card_spec_v0.md` / `_specs/wheel_spec_v0.md` / `_specs/cursor_impl_wheel_v0.md`

---

## 0. この指示書を読む前に

作業開始前に以下を順番に読むこと。読み終えるまで実装を開始しない。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_specs/memory_card_spec_v0.md`（**全文精読。これが今回の正本**）
4. `_specs/wheel_spec_v0.md`（§4 ループ改訂済みを確認する）
5. `_specs/cursor_impl_wheel_v0.md`（前タスクの禁止事項を再確認する）
6. この指示書

---

## 1. このタスクの目的

以下の2つを**同時に**行う。

1. **`WheelItem` → `MemoryCard` への置き換え**  
   3行構造の記憶断片カードをホイールで選べるようにする。

2. **端のループ実装**  
   末尾の次は先頭に・先頭の前は末尾に戻る。  
   （`wheel_spec_v0.md §4` 改訂済み・サトシ判断済み）

達成したいことは1つだけ：

> **ホイールを回すと日本語の記憶断片カード（3行）が1枚ずつ切り替わり、端でループする。**

---

## 2. 作業対象ファイル

### 変更するファイル（既存）

```
src/Models/WheelItem.swift          → MemoryCard.swift に置き換え
src/ViewModels/WheelViewModel.swift → MemoryCard対応・ループ実装
src/Views/WheelView.swift           → MemoryCard 3行表示に対応
```

### 新規作成するファイル

```
src/Models/MemoryCard.swift         → 新モデル定義・モックデータ
```

### 変更してはいけないファイル

```
_docs/ 配下の全ファイル
_specs/ 配下の全ファイル
README.md
AGENTS.md
App/WheelPrototypeApp.swift
App/ContentView.swift
```

---

## 3. 実装内容

### 3-1. MemoryCard.swift（新規作成）

`memory_card_spec_v0.md §2` の定義をそのまま実装する。

```swift
// MemoryCard.swift
// Phase 3 — MemoryCard表示実装
// 仕様: _specs/memory_card_spec_v0.md

import Foundation

struct MemoryCard: Identifiable {
    let id: UUID
    let line1: String  // 年代・季節・時間帯
    let line2: String  // 天気・場所・空気感
    let line3: String  // 行動・記憶・場面
}

// MARK: - Mock Data

extension MemoryCard {
    /// MVP動作確認用モックデータ（7枚・日本語）
    /// 実際の音楽・著作物とは無関係。アプリ名を含まない。
    static let mockCards: [MemoryCard] = [
        MemoryCard(id: UUID(), line1: "2007年 夏",  line2: "雨",        line3: "高校帰り"),
        MemoryCard(id: UUID(), line1: "2011年 冬",  line2: "深夜 1:12", line3: "ひとりの部屋"),
        MemoryCard(id: UUID(), line1: "1999年 秋",  line2: "曇り",      line3: "図書館の帰り道"),
        MemoryCard(id: UUID(), line1: "2003年 春",  line2: "朝",        line3: "始発電車"),
        MemoryCard(id: UUID(), line1: "2009年 夏",  line2: "夕暮れ",    line3: "友達の家"),
        MemoryCard(id: UUID(), line1: "2014年 冬",  line2: "雪",        line3: "アルバイトの帰り"),
        MemoryCard(id: UUID(), line1: "2006年 夏",  line2: "夜",        line3: "祭りの後"),
    ]
}
```

**禁止**：
- `line4` 以降のフィールドを追加しない
- 音楽ファイルパス・再生情報のフィールドを追加しない
- 英語テキストに戻さない

---

### 3-2. WheelItem.swift の扱い

`WheelItem.swift` は **削除する**。  
`MemoryCard.swift` が完全に置き換える。

削除前に、`WheelViewModel.swift` と `WheelView.swift` の `WheelItem` 参照を  
すべて `MemoryCard` に置き換えてからファイルを削除すること。  
（ビルドエラーが出ない状態で削除する）

---

### 3-3. WheelViewModel.swift（変更）

#### 変更点1：型の置き換え

```swift
// 変更前
@Published var items: [WheelItem]

// 変更後
@Published var cards: [MemoryCard]
```

初期値は `MemoryCard.mockCards` を使う。

#### 変更点2：ループ実装

クランプ処理（`if selectedIndex > 0` / `if selectedIndex < items.count - 1`）を  
ループ処理に置き換える。

```swift
// チューニング用定数（ファイル先頭。変更しない）
private let notchAngle: Double = 30.0  // degrees

// ループ実装の方針
// selectedIndex が末尾を超えたら 0 に戻る
// selectedIndex が 0 を下回ったら末尾に戻る
// モジュロ演算（%）またはif文で実装してよい
// ただし cards.count が 0 のとき のガードを入れること
```

**ループ実装の評価軸（`wheel_spec_v0.md §4` より）**：
- 1ノッチずつ選んでいる感覚を維持する
- 強い慣性で複数枚飛び越える動きにしない
- 「果てなく滑る情報帯」の感覚にしない

#### 変更点3：currentCard プロパティ

```swift
// 変更前
var currentTitle: String { items[selectedIndex].title }

// 変更後
var currentCard: MemoryCard { cards[selectedIndex] }
```

#### 変更点4：onCenterTapped

`currentCard` の `line1` を使って確定ログを出す。

```swift
func onCenterTapped() {
    print("Selected: \(currentCard.line1) / \(currentCard.line2) / \(currentCard.line3)")
    // @Published での通知は前実装を踏襲してよい
}
```

---

### 3-4. WheelView.swift（変更）

#### 変更点1：型の参照を更新

`WheelItem` → `MemoryCard` / `items` → `cards` / `currentTitle` → `currentCard` に合わせて参照を更新する。

#### 変更点2：3行表示の実装

選択中カードを3行で表示する。`memory_card_spec_v0.md §4-2` の表示ルールに従う。

```swift
// 実装方針
VStack(spacing: /*適切な間隔*/) {
    Text(viewModel.currentCard.line1)
        // 最も大きく・明るく
    Text(viewModel.currentCard.line2)
        // line1より小さく・やや薄く
    Text(viewModel.currentCard.line3)
        // line2と同等またはやや薄く
}
```

**表示ルール（仕様書 §4-2 より）**：
- line1・line2・line3 でフォントサイズまたはウェイトに差をつける
- 3行を同じ大きさ・同じ濃さで並べない
- ラベル・アイコン・タグ等の装飾を付けない
- フォントは1種類・ウェイト差のみで表現する
- 色はモノクロ（グレースケール）ベースを維持する
- 装飾アニメーション（バウンス・グロー等）は加えない

#### 変更点3：ホイールジェスチャ・慣性

前タスクの実装をそのまま維持する。変更しない。

---

## 4. 実装前にClaudeが出力するもの

**この指示書を受け取ったCursorは、実装前に以下をサトシに提出すること。**

実装に入る前に、WheelView の静止画イメージを HTML で出力する。

出力先：`_design/previews/wheel_memory_card_preview_v0.html`

HTMLに含めること：
- モノクロ背景
- ホイール円形エリア（操作面のイメージ）
- 中央に MemoryCard 3行表示（モックデータ1枚目を使う）
- 中央ボタンエリア

HTMLに含めないこと：
- JavaScript によるインタラクション
- 実際のアニメーション
- SwiftUI固有の表現

**サトシが静止画を確認してOKを出したら実装に進む。**  
OKが出るまで `src/` のファイルを変更しない。

---

## 5. 禁止事項

| 禁止 | 理由 |
|---|---|
| `line4` 以降のフィールド追加 | memory_card_spec §8 |
| 音楽ファイル・MusicKit・AVPlayer の参照 | MVP はモック |
| `ScrollView` / `List` の使用 | wheel_spec §3・§4 |
| 外部ライブラリの追加 | tech_direction §9・§11 |
| 前後カードのスタック・奥行き表現 | memory_card_spec §6（後フェーズ） |
| `UserDefaults` / CoreData / ネットワーク | ローカル状態のみ |
| haptic / tick 音の追加 | スコープ外（別タスク） |
| 英語テキストへの差し戻し | memory_card_spec §8 |
| 慣性を強くする（duration > 0.5） | wheel_spec §5 |
| 正本ファイルの変更 | サトシ承認なし不可 |
| アプリ名・ブランド名の埋め込み | サトシ判断事項 |

---

## 6. 実装チェックリスト

### ビルド確認

- [ ] ビルドエラーが0件である
- [ ] `WheelItem` への参照が残っていない（削除済み）

### 動作確認（シミュレータ）

- [ ] 起動後、MemoryCard の3行が表示される
- [ ] ホイールをドラッグすると MemoryCard が1枚ずつ切り替わる
- [ ] 末尾カードの次は先頭カードに戻る（ループ）
- [ ] 先頭カードの前は末尾カードに戻る（ループ）
- [ ] 中央ボタンタップで Xcode コンソールに3行テキストが出力される
- [ ] 慣性が短く終わる（0.5秒以内）

### 表示確認

- [ ] line1 が最も大きく・明るく表示されている
- [ ] line2・line3 にサイズまたは濃さの差がある
- [ ] 装飾（アイコン・タグ・ラベル）がない
- [ ] モノクロベースの配色になっている

### 禁止事項の非混入確認

- [ ] `ScrollView` / `List` を使っていない
- [ ] 外部ライブラリを追加していない
- [ ] 音楽ファイル・MusicKit への参照がない
- [ ] `UserDefaults` / CoreData を使っていない
- [ ] haptic / tick 音を追加していない
- [ ] 正本ファイルを変更していない

---

## 7. このタスクでやらないこと

- ノッチ角（30°）の変更・チューニング（別タスク）
- haptic / tick 音の実装（別タスク）
- 前後カードのスタック・奥行き表現（後フェーズ）
- Detail 画面・Playing 画面との接続
- 実際の音楽再生・MusicKit 連携
- Boot 画面・Home 画面の作成
- アニメーションの本格チューニング

---

## 8. 完了後にやること

1. §6 チェックリストを全て確認する
2. Xcode コンソールで中央ボタンの出力を確認する
3. サトシに動作確認を依頼する（Mac シミュレータ）
4. サトシの承認後、次タスク（ノッチ角チューニング or haptic）に進む

**サトシの確認なしに次のタスクへ進まない。**

---

## 9. 関連ドキュメント

| ファイル | 参照理由 |
|---|---|
| `_specs/memory_card_spec_v0.md` | 今回の正本・モックデータ・表示ルール |
| `_specs/wheel_spec_v0.md` | ループ仕様（§4改訂済み）・慣性方針 |
| `_specs/cursor_impl_wheel_v0.md` | 前タスク・禁止事項の根拠 |
| `_docs/SYSTEM_CORE.md` | 体験の核・AIが変えてはいけないもの |
| `AGENTS.md` | AI作業ルール全般 |

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-23 | v0 初版（Claude作成） |
