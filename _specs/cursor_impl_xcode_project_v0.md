# Cursor向け実装指示書 — Xcodeプロジェクト作成・WheelView接続 v0

**対象フェーズ**: Phase 3 プロトタイプ実装（2番目のステップ）  
**作成者**: Claude  
**作成日**: 2026-05-23  
**前提コミット**: 68841ee（`feat: add prototype wheel interaction`）  
**前提ドキュメント**: `_specs/cursor_impl_wheel_v0.md` / `_specs/tech_direction_v0.md`

---

## 0. この指示書を読む前に

作業開始前に以下を順番に読むこと。読み終えるまで実装を開始しない。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`
4. `_specs/tech_direction_v0.md`（§2・§3・§11 を精読する）
5. `_specs/cursor_impl_wheel_v0.md`（前タスクの指示書。禁止事項を再確認する）
6. この指示書

---

## 1. このタスクの目的

既存の SwiftUI 3ファイルを iOS Xcode プロジェクトに接続し、  
**シミュレータ上で `WheelView` が表示され、ホイール操作が動作確認できる状態にする。**

達成したいことは1つだけ：

> **シミュレータを起動すると WheelView が表示され、ドラッグでリスト項目が切り替わる。**

「ナビゲーションを作る」「複数画面を繋ぐ」「アプリとして完成させる」はスコープ外。

---

## 2. 前提の確認

作業開始前に以下を確認する。確認できない場合は実装を止めてサトシに報告する。

```bash
git log --oneline -3
# 68841ee feat: add prototype wheel interaction が最新であること

git status
# nothing to commit, working tree clean であること

ls src/Models/WheelItem.swift \
   src/ViewModels/WheelViewModel.swift \
   src/Views/WheelView.swift
# 3ファイルが存在すること
```

---

## 3. 作業対象ファイル

### 新規作成するファイル

```
（プロジェクトルート）/
├── App/
│   ├── WheelPrototypeApp.swift      # @main エントリポイント
│   └── ContentView.swift        # WheelView を呼び出すだけのルートビュー
└── WheelPrototype.xcodeproj/        # Xcode プロジェクトファイル一式
    └── ...
```

> **アプリ名について**：Xcode プロジェクトのバンドル名・表示名は  
> **`WheelPrototype`** とする。  
> これは動作確認用の仮称であり、正式なアプリ名ではない。  
> 正式名称はサトシが別途決定する（`SYSTEM_CORE §4` 参照）。  
> コード中にブランドとして扱う文字列を埋め込まない。

### 変更してよい既存ファイル

なし。`src/` 配下の3ファイルはそのまま使う。

### 変更してはいけないファイル

```
_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
README.md
AGENTS.md
_specs/ 配下の既存ファイル
src/Models/WheelItem.swift
src/ViewModels/WheelViewModel.swift
src/Views/WheelView.swift
```

---

## 4. 実装内容

### 4-1. Xcode プロジェクトの作成

以下の設定でプロジェクトを作成する。

| 設定項目 | 値 |
|---|---|
| テンプレート | iOS App（SwiftUI） |
| Product Name | `WheelPrototype` |
| Interface | SwiftUI |
| Language | Swift |
| Use Core Data | **オフ** |
| Include Tests | **オフ**（MVPでは不要） |
| Minimum Deployment | iOS 16.0 以上（SwiftUI の安定動作範囲） |

**禁止**：
- "Include Tests" をオンにしない
- "Use Core Data" をオンにしない
- CloudKit・iCloud 連携を有効にしない
- Signing に本番証明書を使わない（シミュレータ確認のみのため）

---

### 4-2. 既存3ファイルをプロジェクトに追加

`src/` 配下の3ファイルをプロジェクトのターゲットに追加する。

```
src/Models/WheelItem.swift        → ターゲットに追加
src/ViewModels/WheelViewModel.swift → ターゲットに追加
src/Views/WheelView.swift         → ターゲットに追加
```

**方針**：
- ファイルをコピーしない。**参照（Reference）として追加**する
- ファイルの内容を変更しない
- フォルダ構成（`Models/` `ViewModels/` `Views/`）はそのまま維持する

---

### 4-3. WheelPrototypeApp.swift（エントリポイント）

```swift
// WheelPrototypeApp.swift
// 動作確認用エントリポイント。ホイール動作確認用プロトタイプ。正式アプリ名ではない。

import SwiftUI

@main
struct WheelPrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

### 4-4. ContentView.swift（ルートビュー）

`WheelView` を初期画面として表示するだけ。それ以外は加えない。

```swift
// ContentView.swift
// WheelView を表示するだけのルートビュー。
// ナビゲーション・タブ・モーダル等は追加しない。

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WheelViewModel()

    var body: some View {
        WheelView(viewModel: viewModel)
    }
}
```

**禁止**：
- `NavigationStack` / `NavigationView` / `TabView` を加えない
- `onAppear` でのデータ取得・初期化処理を加えない
- `WheelView` 以外のビューを並べない

---

## 5. ビルド・起動手順

```
1. Xcode でプロジェクトを開く
2. シミュレータを iPhone 15 Pro（または任意の iPhone）に設定する
3. ⌘+B でビルドエラーがないことを確認する
4. ⌘+R でシミュレータを起動する
5. §6 チェックリストの順に確認する
```

---

## 6. 実装チェックリスト

### ビルド確認

- [ ] ビルドエラーが0件である
- [ ] ビルド警告が新たに追加されていない（既存警告は許容）

### 動作確認（シミュレータで実施）

- [ ] シミュレータ起動後、WheelView が表示される
- [ ] ホイールエリアをドラッグすると `selectedIndex` が変化する（項目名が切り替わる）
- [ ] `selectedIndex` が `0` のとき逆方向ドラッグで `-1` にならない
- [ ] `selectedIndex` が末尾のとき正方向ドラッグで範囲外にならない
- [ ] 中央ボタンをタップすると確定動作（Xcode コンソールへの print、またはUI変化）が起きる
- [ ] 指を離して 0.5 秒以内に動きが止まる

### 体感確認（wheel_spec §12 の評価軸）

- [ ] 止まった場所（項目名）が指を離したあとも読める
- [ ] 同じ項目に焦りなく戻せる（迷子にならない）
- [ ] 「情報空間を滑っている」ではなく「何かを回している」感がある

### 禁止事項の非混入確認

- [ ] `src/` 配下の3ファイルを変更していない
- [ ] `ScrollView` / `List` を新たに追加していない
- [ ] 外部ライブラリを追加していない（Swift Package Manager / CocoaPods 等）
- [ ] MusicKit / AVPlayer / 音楽ファイルへの参照がない
- [ ] `UserDefaults` / CoreData / CloudKit を使っていない
- [ ] ネットワーク通信を含んでいない
- [ ] haptic / tick 音を追加していない
- [ ] 正本ファイルを変更していない

---

## 7. 禁止事項一覧

| 禁止 | 理由 |
|---|---|
| `src/` 配下3ファイルの変更 | 前タスクの成果物。変更は別指示書で行う |
| Swift Package Manager / CocoaPods での外部ライブラリ追加 | tech_direction §9・§11 禁止 |
| MusicKit / AVPlayer / 音楽ファイル参照 | MVP はモック再生のみ |
| haptic / tick 音の実装 | 次フェーズ以降 |
| `NavigationStack` / `TabView` 等のナビゲーション追加 | Boot・Home 等との接続は別タスク |
| Core Data / CloudKit / iCloud の有効化 | ローカル状態のみ |
| ネットワーク通信 | 同上 |
| 本番 Signing / App Store Connect 設定 | 配布方針はサトシ判断事項 |
| アプリ名・ブランド名のコード埋め込み | `WheelPrototype` はホイール動作確認用の仮名。正式アプリ名はサトシが決定 |
| 正本ファイルの変更 | サトシ承認なしに変更不可 |

---

## 8. 迷ったときの判断順序

1. `tech_direction_v0.md` §2「採用する技術方向」に照らす
2. `wheel_spec_v0.md` §4「重要思想」に照らす
3. `SYSTEM_CORE.md` §4「AIが勝手に変えてはいけないもの」に照らす
4. それでも判断できない場合は **実装せずサトシに確認する**

---

## 9. このタスクでやらないこと

- Boot 画面・Home 画面・Moments 画面の作成・接続
- 実際の音楽再生
- MusicKit 連携の受け口実装
- haptic / tick 音
- CoreHaptics の導入
- ナビゲーション構造の設計
- テーマ・カラーパレットの確定
- TestFlight / App Store 配布設定
- アプリ名・ブランドの確定

---

## 10. 完了後にやること

1. §6 チェックリストを全て確認する
2. 30°のノッチ感・0.26s の慣性について「重い／軽い／ちょうどよい」をメモする
3. サトシに動作確認を依頼する
4. サトシの承認後、次タスクに進む

**サトシの確認なしに次のタスクへ進まない。**

---

## 11. 関連ドキュメント

| ファイル | 参照理由 |
|---|---|
| `_specs/cursor_impl_wheel_v0.md` | 前タスク指示書・禁止事項の根拠 |
| `_specs/wheel_spec_v0.md` | 体感の正本・チェックリストの根拠 |
| `_specs/tech_direction_v0.md` | 技術スタック・禁止ライブラリの根拠 |
| `_docs/SYSTEM_CORE.md` | 体験の核・AIが変えてはいけないもの |
| `AGENTS.md` | AI作業ルール全般 |

---

## 変更履歴

| 日付 | 内容 |
|---|---|
| 2026-05-23 | v0 初版（Claude作成） |
