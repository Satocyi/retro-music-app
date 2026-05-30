# Cursor向け実装指示書 — 写真MVP UI v0

**対象フェーズ**: Phase 2〜3（写真MVP UI・低コストフィルター接続）
**作成日**: 2026-05-30
**前提コミット**: `7da2b1c`（`docs: add Claude handover after photo MVP definition`）
**前提ドキュメント**:

- `_docs/SYSTEM_CORE.md`
- `_docs/SYSTEM_CURRENT.md`
- `_design/ui_concept.md`
- `_design/reference_direction.md`
- `_specs/photo_mvp_experience_v0.md`
- `src/Views/MemoryTunerView.swift`（黒ホイール版・見た目移植第一段階）

**本書の位置づけ**: 次回 Cursor セッションでコードを書くための方針書。**今回はコード変更しない。**

---

## 0. 目的

現在の黒ホイールUIを、音楽/記憶カード選択ではなく、写真の空気をチューニングするUIへ転用する。

初期MVPでは、フォトライブラリから写真を選び、ホイールで年代・季節・時間帯・天気・質感を選び、iPhone内処理の写真フィルターで見た目を変える。

体験の成立確認が第一目的。高精度な再現より、「選ぶと見た目が明確に変わる」ことを優先する。

---

## 1. 前提

以下を実装の不変条件とする。

- 音楽機能は本線から外す
- MusicKit / Spotify / 音楽ファイル / 音楽再生は実装しない
- AI画像生成APIは使わない
- サーバー送信しない
- 写真は端末内で処理する
- 初期MVPではフォトライブラリ入力を優先する
- カメラ撮影は後回しでもよい

プロダクト定義（正本と整合）:

```text
iPhone写真を、ホイール操作で「記憶の空気」に変換するレトロデバイス型アプリ
```

技術方針（`SYSTEM_CURRENT.md` / `photo_mvp_experience_v0.md` と一致）:

- 対象OS: iOS専用で開始
- UI: SwiftUI中心（`MemoryTunerView.swift` を主画面として継続利用）
- 画像処理: Core Image 等の端末内処理を想定
- 既存の銀筐体・暗緑LCD・黒ホイールの視覚基準は維持し、意味づけだけを写真チューニングへ差し替える

---

## 2. 今回実装する体験

ユーザーがたどる流れ（MVPの最小ループ）:

```text
1. アプリを開く
2. レトロデバイスUIが表示される
3. 「写真を選ぶ」導線からフォトライブラリを開く
4. 写真を選ぶ
5. LCDに現在の調整項目が表示される
6. 写真プレビューが表示される
7. ホイールで選択中項目の値を変更する
8. MENU相当の操作で調整項目を切り替える
9. OKで現在のフィルター状態を確定する
10. 保存は初期実装ではスタブでもよい
```

確定の意味（初期MVP）:

- OK押下で「この組み合わせでプレビュー表示を固定」または「確定ログ／短い一区切り演出」まででよい
- フォトライブラリへの書き戻し・共有は後続（スタブ可）

---

## 3. 画面構成

既存 `MemoryTunerView.swift` のレイアウト骨格（上部LED行 → LCD → ホイール）を活かし、写真MVP用に次のゾーン構成へ拡張する。

```text
上部：写真プレビュー（新規）
中部：LCDステータス表示（5調整項目・既存ドットマトリクス流用）
下部：黒ホイール（既存操作・意味変更）
中央OK：確定（既存）
MENU相当：調整項目切替（既存 bottomButtons の MENU ロジック流用 or 一時表示）
```

方針:

- まずは1画面内に収める（画面遷移は増やさない）
- 写真プレビューは大きすぎず、レトロ端末UIの世界観を優先する
- LCDには5項目を表示する（`_specs/photo_mvp_experience_v0.md` と同じ）
- 選択中項目だけ淡く強調する（現行 `dotMatrixRow` の `isActive` 強調を流用）

現行実装との対応（参考）:

| 現行 | 写真MVPへ |
|------|-----------|
| 上部 `statusLEDRow` のみ | その上またはLCD直上にプレビュー帯を追加 |
| LCD 5行（年/季節/天気/場所/情景） | 年代/季節/時間帯/天気/質感 にラベル・候補を差し替え |
| ホイール回転 → `activeSlotIndex` の値変更 | 同じ。`activeControl` に名称変更推奨 |
| 中央 OK | フィルター状態の確定 |
| `bottomButtons`（非表示・保持） | MENU で項目切替。必要なら一時表示 |

プレビュー領域のサイズ目安（実装時の判断材料・厳密値ではない）:

- 横は LCD ベゼル幅（`lcdW`）に揃えるか、筐体左右パディング（28pt）内に収める
- 縦は「LCD＋ホイールが画面内に収まる」ことを優先し、`GeometryReader` の既存計算（`wheelCapV` 等）を壊さないよう再配分する

---

## 4. 状態設計

### 4-1. 必須状態候補

```swift
// 写真
var selectedImage: UIImage?          // または Image / CIImage ラッパー

// 調整UI
var activeControl: PhotoTuningControl
var eraIndex: Int
var seasonIndex: Int
var timeIndex: Int
var weatherIndex: Int
var textureIndex: Int

// 処理
var isProcessing: Bool              // フィルター再計算中
var filterPreviewImage: UIImage?    // 適用後プレビュー（元画像は保持）
var isConfirmed: Bool               // OK確定後の一区切り（任意）
```

現行 `MemoryTunerView` の置き換え対応:

| 現行 | 写真MVP |
|------|---------|
| `activeSlotIndex` | `activeControl`（enum） |
| `slotValueIndices: [Int]` | 各 `*Index` または単一配列＋enum（初回は配列でも可） |
| `statusLine` / `okPressed` | 確定・プレースホルダー文言に再利用可 |

### 4-2. 調整項目 enum 候補

```swift
enum PhotoTuningControl: CaseIterable {
    case era
    case season
    case timeOfDay
    case weather
    case texture
}
```

LCD・MENU・ホイールの「どの行が active か」はこの enum と同期する。

### 4-3. 候補値（表示文言）

| 項目 | 候補（インデックス順） |
|------|------------------------|
| 年代 `era` | 1998 / 2003 / 2007 / 2012 |
| 季節 `season` | 春 / 夏 / 秋 / 冬 |
| 時間帯 `timeOfDay` | 朝 / 昼 / 夕方 / 夜 |
| 天気 `weather` | 晴れ / 曇り / 雨 / 湿った空気 |
| 質感 `texture` | 古いデジカメ / 低彩度フィルム / くすんだ緑 / 夜の室内 / 色あせ |

LCDラベル案（短い日本語＋必要なら英字サブ）:

- 年代 → `年` または `ERA`
- 季節 → `季`
- 時間帯 → `時`
- 天気 → `天`
- 質感 → `質`

【未確定・実装時にサトシ確認可】正式なLCDヘッダー文言（現行 `MEMORY TUNER` の置き換え）。初期案: `PHOTO TUNER` または `MEMORY PHOTO`。

### 4-4. 値変更とフィルター再計算

- ホイールで `activeControl` に対応する index が変わったら、デバウンスなしで即プレビュー更新してよい（重い場合は `isProcessing` と短い遅延を検討）
- 5軸の組み合わせから、内部では「プリセットに近いパラメータセット」へマッピングする（§8）

---

## 5. 写真入力

### 5-1. 優先手段

初期実装では **フォトライブラリ** を第1優先とする。

実装候補:

```text
PhotosPicker（SwiftUI）
```

- `PhotosUI` フレームワーク
- 選択結果を `Data` / `UIImage` に変換し `selectedImage` へ格納

### 5-2. UI導線

- 写真未選択時: プレビュー領域にタップ可能なプレースホルダー（§6）
- 選択後: 同領域にサムネイル／フィット表示。再タップで再選択可

### 5-3. カメラ

- 今回の必須スコープ外
- `UIImagePickerController` / `AVCaptureSession` は後続

### 5-4. 権限・プロジェクト変更（実装前に明示すること）

写真ライブラリ利用時、以下の変更が **発生しうる**。Cursor は変更前に理由をコミットメッセージまたは PR 説明に書くこと。

| 変更箇所 | 内容 |
|----------|------|
| `Info.plist`（または target の Privacy 設定） | `NSPhotoLibraryUsageDescription`（読み取り）。保存を入れる場合は `NSPhotoLibraryAddUsageDescription` |
| `WheelPrototype.xcodeproj` | PhotosUI のリンク、Deployment Target の確認 |
| Entitlements | 初期MVPの読み取りのみなら追加不要のことが多い（保存実装時は再確認） |

【判断が必要】権限ダイアログの日本語文言の最終文案はサトシ確認推奨。実装時はプレースホルダー文言で進めず、指示書に記載した案を暫定利用する:

```text
「記憶の空気」に変換するために、選択した写真を端末内で表示・加工します。写真はサーバーに送信しません。
```

---

## 6. 写真プレビュー

### 6-1. 表示方針

- 選択前: プレースホルダー表示
- 選択後: 元画像を表示し、フィルター適用後の見た目をプレビューに反映
- 元画像そのものは上書きしない（メモリ上の別バッファ／`filterPreviewImage`）
- 保存処理は後続でよい（OK確定はプレビュー固定またはログまで）

### 6-2. プレースホルダー

文言候補（併記可）:

```text
PHOTO INPUT
写真を選ぶ
```

視覚: 暗めの矩形＋モノスペース英字＋短い日本語。レトロ端末の「入力待ち」感。派手なイラストは不要。

### 6-3. レイアウト

- `aspectRatio` は写真に合わせ `fit`（レターボックス可）
- 角丸・細枠で LCD ベゼルと質感を揃える
- 加工中は `isProcessing` で軽いオーバーレイまたは LCD ステータス行の更新（`●PROCESSING` 等）

---

## 7. ホイール調整UI

### 7-1. 意味の変更

| 旧（記憶カード／音楽的ムード） | 新（写真の空気） |
|-------------------------------|------------------|
| 年・場所・情景など記憶スロット | 年代・季節・時間帯・天気・質感 |
| 組み合わせテキストの確定 | フィルターパラメータの確定 |

ホイールの **見た目・ノッチ・ドラッグ角度・慣性** は現行 `wheelDragGesture` / `applyWheelDelta` を維持する。

### 7-2. 操作方針

- ホイール右側タップまたは回転操作（時計回り）で値を進める
- ホイール左側タップまたは回転操作（反時計回り）で値を戻す
- 実装上は現行と同様、リング上のドラッグ角度差分で `stepActiveSlotValue(direction:)` 相当を呼ぶ
- MENU相当で `activeControl` を次へ進める（循環）
- OKで現在状態を確定する

### 7-3. MENU・下部ボタン

現行コードでは `bottomButtons` が **未配置（将来用に保持）**。

実装優先順位:

1. 既存 `resinKey(title: "MENU", ...)` を画面下部に再表示し、`activeSlotIndex` 更新ロジックを `activeControl` に接続
2. それでも操作が分かりにくい場合のみ、LCD直下またはホイール上に小さな `MENU` テキストボタンを一時追加（DEBUG 時のみ等は避け、本番UIとして最小表示）

「選択」「生成 →」キーは写真MVPでは **使わない**（削除または非表示）。音楽・生成連想を避ける。

### 7-4. LCDとの連動

- `activeControl` に対応する行だけ強調（現行 `dotMatrixRow` の `isActive`）
- ヘッダー右の `●STANDBY` は、写真未選択時 STANDBY、選択後 READY、処理中 PROCESSING などに更新可

---

## 8. 初期フィルター

### 8-1. 処理方式

初期MVPでは **Core Image**（`CIFilter` チェーン）等の端末内処理を想定する。

組み合わせるパラメータ軸:

```text
brightness
contrast
saturation
temperature（色温度）
vignette
grain/noise（粒状感）
```

### 8-2. プリセットとの関係

`_specs/photo_mvp_experience_v0.md` の象徴プリセットを、5軸の組み合わせから **近似マッピング** する。

| プリセット名 | おおよその軸の寄せ |
|--------------|-------------------|
| 1998年 夕方 | 年代=1998、時間帯=夕方、質感=色あせ寄り |
| 2003年 夏 | 年代=2003、季節=夏、質感=古いデジカメ |
| 雨の日の帰り道 | 天気=雨、時間帯=夕方〜夜 |
| 夜の室内 | 時間帯=夜、質感=夜の室内 |
| 色あせた記憶 | 質感=色あせ、全体的に低彩度 |

実装方針:

- 各 `eraIndex` 等に **ベース係数テーブル** を持つ
- 複数軸を加算／乗算で合成し、最終的に `CIFilter` へ渡す
- 初期実装では、すべてを高精度に再現しなくてよい。**選択に応じて明確に見た目が変わる** ことを最優先

### 8-3. パフォーマンス

- プレビュー解像度は画面表示用にダウンスケールしてよい
- 実機で重い場合は、ホイール連続操作時のスロットリングを検討（Phase 2 実機確認）

### 8-4. ファイル分割

初回は `MemoryTunerView.swift` 内に `applyPhotoFilter(...)` を仮置きしてよい。ロジックが 80行を超えたら `src/Utils/PhotoFilterProcessor.swift` へ抽出。

---

## 9. 初期MVPでやらないこと

以下は **実装しない・コードに入れない**。

```text
- AI画像生成API
- 写真の中身の描き換え
- 背景変更
- 人物・建物・空などの生成変更
- サーバー送信
- クラウド保存
- SNS投稿
- 課金
- カメラ撮影の本実装
- 高度な写真編集パネル
- 大量プリセット
- MusicKit / Spotify / 音楽再生
- 音楽ファイルの読み込み
- 外部ライブラリの追加（SPM / CocoaPods 等）
- 外部APIキー・エンドポイント
```

旧音楽プロトタイプ資産（`WheelView.swift` / `MemoryCard.swift` 等）の **削除は今回不要**。触らない・本線に接続しない。

---

## 10. 変更対象ファイル候補

### 10-1. 必須（主変更）

```text
src/Views/MemoryTunerView.swift
```

内容:

- プレビュー領域追加
- LCD 5項目の差し替え
- 状態・PhotosPicker・フィルター接続
- MENU 再表示（方針に応じて）

### 10-2. エントリ確認（必要に応じて）

```text
App/ContentView.swift          … MemoryTunerView を表示しているか確認のみ
App/WheelPrototypeApp.swift    … 変更不要想定
```

### 10-3. 新規作成候補（必要なら）

```text
src/Models/PhotoTuningControl.swift
src/Models/PhotoTuningPreset.swift
src/Views/PhotoPickerView.swift      … PhotosPicker をラップする場合
src/Utils/PhotoFilterProcessor.swift … Core Image チェーン
```

**初回実装ではファイルを増やしすぎない。** 単純な状態とフィルターは `MemoryTunerView.swift` 内に仮実装してよい。分割は第二段階。

### 10-4. 触らない／今回変更しない

```text
_docs/
_design/
README.md
AGENTS.md
repomix-output.xml
web/（別検証用。本線の iOS MVP と混同しない）
```

`WheelPrototype.xcodeproj` / `Info.plist` は **写真権限・PhotosUI のために変更しうる**（§5-4）。それ以外の無関係な設定変更はしない。

---

## 11. 受け入れ条件

Mac / Xcode / シミュレーターでの確認を想定した完了定義:

```text
- ビルド可能なSwiftUIコードにする
- フォトライブラリから写真を選べる
- 選んだ写真が画面に表示される
- LCDに5項目（年代・季節・時間帯・天気・質感）が表示される
- activeControl が視覚的に分かる（選択行の強調）
- ホイール操作で選択中項目の値が変わる
- 値変更に応じて写真の見た目（プレビュー）が変わる
- AI画像生成APIを使っていない
- サーバー送信していない
- 音楽関連機能を追加していない
```

任意（初期MVPでスタブ可）:

- OK押下で確定のフィードバック（ログ・短いアニメ・ステータス文言）
- 写真アルバムへの保存

---

## 12. 実装後チェック

### 12-1. Git（Mac または Windows）

```powershell
git diff --check
git diff --stat
```

音楽・外部依存の混入確認用:

```powershell
git diff --name-only
```

### 12-2. Mac / Xcode（実装担当が実施）

- `WheelPrototype` をビルド（Debug）
- シミュレーターまたは実機で: 写真選択 → プレビュー → ホイール変更 → 見た目変化 → OK
- コンソールにネットワーク送信・APIキー利用がないこと

### 12-3. Windows でできる確認（Mac 確認前）

```text
- 音楽関連コードを追加していないか（MusicKit, Spotify, AVAudioPlayer 等の grep）
- 外部APIキーを追加していないか
- 外部ライブラリを追加していないか（Package.swift, Podfile 等）
- Xcode project / Info.plist 変更が必要な場合、その理由がコミット説明に明記されているか
- _docs / _design 正本を勝手に変更していないか
```

推奨 grep 例（PowerShell）:

```powershell
git diff | Select-String -Pattern "MusicKit|Spotify|openai|api\.|URLSession.*http" -CaseSensitive:$false
```

---

## 関連

- `_specs/photo_mvp_experience_v0.md` — MVP体験・5項目・プリセット定義
- `_specs/cursor_impl_memory_card_v0.md` — 旧記憶カード実装（参考。本線ではない）
- `Handover/ai_handover/claude_handover_20260530.md` — 写真MVP定義直後の引き継ぎ

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-30 | 初版。写真MVP UI 実装方針のみ。コード未変更。 |
