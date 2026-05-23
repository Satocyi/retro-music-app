# Cursor向け実装指示書 — ホイールUI基本動作 v0

**対象フェーズ**: Phase 3 プロトタイプ実装（最初のステップ）  
**作成者**: Claude  
**作成日**: 2026-05-23  
**前提ドキュメント**: `_specs/wheel_spec_v0.md` / `_specs/tech_direction_v0.md` / `_specs/mvp_flow_v0.md`

---

## 0. この指示書を読む前に

作業開始前に以下を順番に読むこと。読み終えるまで実装を開始しない。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`
4. `_specs/wheel_spec_v0.md`（**特に §3・§4・§5・§16・§17 を精読する**）
5. `_specs/tech_direction_v0.md`
6. この指示書

---

## 1. このタスクの目的

`_specs/wheel_spec_v0.md` が定義した「**機械を触っている感覚**」を、SwiftUI上で最初に動く形にする。

達成したいことは1つだけ：

> **ホイールを指で回すと、リスト項目がひとつずつ進む。その動きが「機械感」として体感できる。**

「音楽を再生できる」「画面が遷移できる」はこのタスクのスコープ外。

---

## 2. 対象ファイルと配置

以下のファイルを新規作成する。既存ファイルは変更しない。

```
src/
├── Views/
│   └── WheelView.swift          # ホイール本体のSwiftUIビュー
├── ViewModels/
│   └── WheelViewModel.swift     # ホイール状態管理
└── Models/
    └── WheelItem.swift          # リスト項目のモデル（モックデータ含む）
```

**ルール**：
- `src/` 配下以外にファイルを作らない
- 既存ファイルを変更する場合は、その理由をコメントに書く
- 正本ファイル（`_docs/` 配下・`AGENTS.md`・`README.md`）には触らない

---

## 3. 実装内容

### 3-1. WheelItem.swift（モデル）

モックデータとしての項目リストを定義する。

```swift
// 実装すること
struct WheelItem: Identifiable {
    let id: UUID
    let title: String
}

// モックデータ（最低5件・最大10件）
// タイトルは仮の文字列でよい（例："Late Night Drive", "1998 Summer" 等）
// 音楽ファイルや実楽曲データは使わない
```

**禁止**：
- 実際の音楽ファイルパスや音楽APIへの参照を含めない
- UserDefaultsやCoreDataへの保存を実装しない
- ネットワーク通信を含めない

---

### 3-2. WheelViewModel.swift（状態管理）

ホイールの回転状態とリスト選択状態を管理する。

```swift
// 実装すること
class WheelViewModel: ObservableObject {
    @Published var items: [WheelItem]       // 表示するリスト項目
    @Published var selectedIndex: Int        // 現在選択中の項目インデックス
    @Published var wheelAngle: Double        // ホイールの現在角度（ジェスチャ追跡用）

    // ホイール回転時に呼ばれる
    func onWheelRotated(delta: Double)
    // 回転量deltaに応じてselectedIndexを進める／戻す
    // 1ノッチ分（後述）を超えるたびにindexが1変化する

    // 中央ボタンタップ時
    func onCenterTapped()
    // MVP: print or @Published で確定を通知するだけでよい
}
```

**ノッチ感の考え方**：
- `delta` が `notchAngle` を超えるたびに `selectedIndex` が1変化する
- `notchAngle` の初期値は **30°** とする
- `notchAngle` はファイル先頭に定数として分離する（後でサトシが実機で触って調整する）

```swift
// チューニング用定数。実機確認後に調整する。ここ以外に角度の数値を書かない。
private let notchAngle: Double = 30.0  // degrees
```

- `selectedIndex` は `0 ..< items.count` の範囲でクランプする（無限ループにしない）

---

### 3-3. WheelView.swift（ビュー）

画面に表示するホイールUIコンポーネント。

#### レイアウトの構成要素（最小限）

| 要素 | 役割 |
|------|------|
| ホイール円形エリア | 回転ジェスチャを受け取る主操作面 |
| 中央ボタン | `onCenterTapped()` を呼ぶタップ領域 |
| 現在選択中の項目名 | `selectedIndex` に対応する `WheelItem.title` を表示 |

**細部のデザイン指定はしない**。色・フォント・サイズはMVPでは仮でよい。ただし以下は守る：

- モノクロ（グレースケール）ベースで作る
- 装飾アニメーション（バウンス・グロー・パーティクル等）は加えない
- ホイール円形エリアはタップ可能な最小サイズを確保する（`frame` で明示）

#### ジェスチャ実装の方針

```swift
// DragGesture を使って回転角度を計算する
// ホイール中心からの角度差を delta として WheelViewModel.onWheelRotated(delta:) に渡す
// UIScrollView / List / ScrollView のスクロール動作は使わない
// （「無限スクロール感」につながるため wheel_spec §3・§4 禁止事項）
```

**慣性の扱い**：
- `DragGesture` の `.onEnded` で velocity を取得し、**弱い慣性**だけ適用する
- `withAnimation(.easeOut(duration: 0.2〜0.3))` 程度の短い余韻にとどめる
- `UIScrollView` の慣性や `ScrollViewReader` を流用しない

---

## 4. 禁止事項（wheel_spec §16・§17 より抜粋・実装向けに翻訳）

以下は、指示なく追加してはいけない。判断に迷ったら実装を止めてサトシに確認する。

| 禁止 | 理由 |
|------|------|
| `ScrollView` / `List` / `UIScrollView` でのスクロール実装 | 「無限スクロール感」になるため |
| 慣性を強くする（`duration > 0.5` 等の長い余韻） | 「効率スクロール」に近づくため |
| tick音・hapticの実装 | このタスクのスコープ外（次フェーズ） |
| 長押しジェスチャの追加 | MVP では補助・稀（wheel_spec §10） |
| MusicKit / AVPlayer / 音楽ファイルの参照 | MVP はモック再生のみ |
| Firebase / 外部ライブラリのimport | tech_direction §9・§11 禁止 |
| `@AppStorage` / `UserDefaults` / CoreData | ローカル状態のみ（外部保存しない） |
| ネットワーク通信 | 同上 |
| Android / React Native / Flutter 前提のコード | iOS / SwiftUI 専用 |
| アプリ名・ブランド名の文字列を埋め込む | サトシ判断事項 |

---

## 5. 実装チェックリスト

実装後、以下を順番に確認する。

### 動作確認（シミュレータで実施）

- [ ] ホイールエリアを指でなぞると `selectedIndex` が変化する
- [ ] 表示中の項目名が `selectedIndex` に連動して切り替わる
- [ ] `selectedIndex` が `0` のとき、さらに逆方向に回しても `-1` にならない（クランプされる）
- [ ] `selectedIndex` が末尾のとき、さらに正方向に回しても範囲外にならない
- [ ] 中央ボタンをタップすると何らかの確定動作（printまたはUI変化）が起きる
- [ ] 慣性が短く終わる（指を離して0.5秒以内に止まる）

### 体感確認（wheel_spec §12 の評価軸で確認）

- [ ] 止まった場所（選択中項目）が指を離したあとも読める
- [ ] 焦りなしで同じ項目に戻せる（探索の不安を煽られない）
- [ ] 回している最中、「情報空間を滑っている」感じではなく「何かを回している」感じがある

### 禁止事項の非混入確認

- [ ] `ScrollView` / `List` を使っていない
- [ ] 外部ライブラリをimportしていない
- [ ] 音楽ファイル・MusicKitへの参照がない
- [ ] アプリ名の文字列を埋め込んでいない

---

## 6. 迷ったときの判断順序

1. `wheel_spec_v0.md` の §3「回転操作の思想」と §4「重要思想」に照らす
2. `SYSTEM_CORE.md` の「体験の核」に照らす
3. それでも判断できない場合は **実装せずサトシに確認する**

「より便利に」「より気持ちよく」を単独KPIにしない。

---

## 7. このタスクでやらないこと

以下は意図的にスコープ外とする。次フェーズ以降。

- tick音・hapticフィードバック
- Boot画面・Home画面・Moments画面との接続
- 実際の音楽再生
- MusicKit連携の受け口実装
- CoreHapticsの導入
- アニメーションの本格チューニング
- テーマ・カラーパレットの確定
- アプリ名・ブランドの反映

---

## 8. 完了後にやること

1. シミュレータで §5 チェックリストを全て確認する
2. 気になった点・迷った点をメモに残す（HandoverまたはSlack等）
3. サトシに動作確認を依頼する
4. サトシの承認後、次タスク（Boot画面 or tick音・haptic）に進む

**サトシの確認なしに次のタスクへ進まない。**

---

## 9. 関連ドキュメント

| ファイル | 参照理由 |
|----------|----------|
| `_specs/wheel_spec_v0.md` | 体感の正本・禁止事項の根拠 |
| `_specs/tech_direction_v0.md` | 技術スタック・禁止ライブラリの根拠 |
| `_specs/mvp_flow_v0.md` | ホイールが担う画面上の役割（Moments層） |
| `_docs/SYSTEM_CORE.md` | 体験の核・AIが変えてはいけないもの |
| `AGENTS.md` | AI作業ルール全般 |

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-23 | v0 初版（Claude作成） |
| 2026-05-23 | v0.1 ノッチ角度初期値を30°として確定・定数分離の実装例を追記（サトシ承認） |
