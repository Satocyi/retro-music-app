# retro-music-app handover

作成: ChatGPT  
日付: 2026-05-24  
対象プロジェクト: `retro-music-app`

---

## 0. 現在地

- 最新確認済みcommit: `e86e00c`
- `origin/master` 同期済み（Windows側）
- 直近のWindows側working tree: clean
- Mac側はXcode確認後に `project.pbxproj` / `xcshareddata/xcschemes` / `project.xcworkspace` が自動変更されるため、確認後は戻す運用を継続
- Xcodeプロジェクト: `WheelPrototype.xcodeproj`
- Product Name: `WheelPrototype`（仮称。正式アプリ名ではない）
- iOS / SwiftUI / モック再生方針は維持
- MusicKit本実装、音楽ファイル、haptic、tick音、Boot接続、外部ライブラリ追加は未実施

---

## 1. このセッションで扱った大きな論点

### 1-1. UI方向の再検討

現行の白背景・簡易Web風UIは、ユーザー評価として「ダサい」「iPod/昔のガジェット感がない」「初心者HTMLのように見える」という問題があった。

そのため、以下の方向を検討した。

- レトロiPodコピーではなく、AI記憶装置 / Memory Tuner 的な方向
- 黒基調・発光・AI端末感
- ただしSFゲーム寄りになりすぎないよう、古い電子機器・2000年代ガジェット感を足す
- 年・季節・天気・場所・情景を独立スロット化する構想
- MENUでアクティブスロットを切り替え、ホイールで対象スロットだけ変える構想

ただし、今回の結論として、独立スロット本実装にはまだ入らない。

---

## 2. 視覚基準PNGの確定

複数のAI生成／HTMLプレビュー／CSS再現を試した結果、最終的に以下を一次視覚基準として扱うことにした。

```text
_design/previews/assets/reference_memory_tuner_original.png
_design/previews/memory_tuner_ios_portrait_preview_v1.html
```

重要な判断:

- このPNGを「見た目の一次基準」とする
- CSS/HTMLでさらに筐体・LCD・ホイール・ボタンを分解再現し続けない
- 画像としてはこの方向で十分
- ただし、この画像をそのままアプリUIの最終実装にするかは別問題

---

## 3. 画像ベースMVPシェルを実装

### 3-1. 作成した指示書

Cursorが以下を作成した。

```text
_specs/cursor_impl_image_mvp_shell_v0.md
```

内容:

- `reference_memory_tuner_original.png` を一次基準として固定
- SwiftUIで筐体・LCD・ホイール・下ボタンを再描画しない
- 単一画像として表示する
- 操作は透明ヒットレイヤーで受ける
- LCD文字の動的差し替えはしない
- WheelViewModel / MemoryCard は本フェーズでは原則触らない
- CSS/SwiftUIベクター再現志向の `cursor_impl_visual_v1.md` とは方向が違うことを明記

### 3-2. 実装されたファイル

commit:

```text
e86e00c feat: add image-based memory tuner shell
```

変更内容:

```text
App/Assets.xcassets/
App/Assets.xcassets/memory_tuner_device_ref.imageset/
App/Assets.xcassets/memory_tuner_device_ref.imageset/memory_tuner_device_ref.png
App/ContentView.swift
src/Views/MemoryTunerImageShellView.swift
_design/previews/assets/reference_memory_tuner_original.png
_design/previews/memory_tuner_ios_portrait_preview_v1.html
_specs/cursor_impl_image_mvp_shell_v0.md
WheelPrototype.xcodeproj/project.pbxproj
```

実装方針:

- `ContentView` は `MemoryTunerImageShellView()` のみ表示
- `MemoryTunerImageShellView` は画像アセットを `aspectRatio(.fit)` で表示
- 透明ヒット領域で MENU / 選択 / 生成 / wheel を受ける設計
- Loggerで `lastGesture=...` を出す方針
- `WheelViewModel` / `MemoryCard` / 既存 `WheelView` は削除・変更しない

---

## 4. Mac確認結果

Macで `git pull` 後、iPhone Simulatorで画像表示は確認できた。

確認できたこと:

- Buildは通った
- 参照PNGが画面に表示された
- SwiftUI再現ではなく、画像ベース表示になった
- 見た目の迷走は一旦止められた

問題:

- 画面は「ただの画像」に見える
- タップしても反応が分からない
- 透明ヒット領域方式は操作確認として分かりにくい
- 色付きヒット領域を出したところ、位置ズレや操作不能感があり、アプリらしさがない

---

## 5. DEBUG HUD / ヒット領域可視化の追加

画像ベースシェルのタップ確認のため、Cursorが `MemoryTunerImageShellView.swift` に以下を追加した。

- `#if DEBUG` のHUD
- `lastGesture=none/menu/select/generate/wheel` 表示
- `print("lastGesture=...")`
- ヒット領域の色付き可視化
- `showDebugHitAreas = true`
- `Rectangle().fill(...).contentShape(Rectangle())`

その後、係数調整や `.contentShape` / `.offset` / `.position` 周りの修正も行われた。

ただし、ユーザー評価としては以下。

- 変な色が付いているだけに見える
- 操作が効いている感がない
- 画像ベースMVPは、見た目確認には有効だが、操作感確認には弱い

このDEBUG修正がcommit済みかどうかは未確認。次セッション開始時に `git status` で確認すること。

---

## 6. 現時点の重要な結論

### 6-1. 画像ベース方式の評価

画像ベース方式は、見た目確認には正しい。

しかし、アプリとしては弱い。

理由:

- ただの画像の上に透明ボタンを置いているだけに見える
- 操作反応が自然ではない
- LCD・ホイール・ボタンの状態変化を出しにくい
- 触って楽しいUIになりにくい

### 6-2. SwiftUI方式への再評価

アプリとして成立しやすいのは、昨日までのようなSwiftUI構成UI。

ただし、前回の失敗は「SwiftUI方式そのものが悪い」のではなく、以下が原因。

- 一気に全部を参照PNGに似せようとした
- Cursor/AIに「かっこよくして」と広く任せた
- 見た目の基準がブレた
- CSS/SwiftUIで筐体・LCD・ホイール・ボタンを同時に調整したため比較不能になった

### 6-3. 次の方針

次は、以下の整理で再出発する。

```text
静止画PNG = 見た目の正本・デザイン仕様
SwiftUI = 実際に触るアプリUI
```

つまり:

- 画像を本実装にするのではなく、デザイン仕様書として使う
- SwiftUIで再構成する
- ただし100%再現は目指さない
- まず操作できるUIとして成立させる
- 見た目はPNGに寄せるが、完全一致は捨てる
- 透明ヒット調整は一旦停止

---

## 7. 次セッションで最初にやること

まず以下を確認する。

```powershell
git status
git log --oneline -5
```

確認ポイント:

- DEBUG HUD / ヒット領域修正が未commitで残っていないか
- 最新commitが `e86e00c` のままか、それ以降があるか
- working tree がcleanか

そのうえで、次の方針整理を行う。

次の自然なタスク:

```text
参照PNGをデザイン正本として使いながら、SwiftUI構成UIへ戻すための実装方針を整理する
```

まだいきなり実装しない。

---

## 8. 次に作るべき指示書候補

次は以下のような指示書が必要。

```text
_specs/cursor_impl_swiftui_memory_tuner_v0.md
```

目的:

- 画像ベース本実装ではなく、SwiftUI構成UIに戻す
- ただし参照PNGをデザイン正本として使う
- 一気に全部似せない
- まず操作可能なUIを作る

含めるべき方針:

1. `reference_memory_tuner_original.png` は見た目基準として維持
2. SwiftUIで以下を構成する
   - 本体筐体
   - LCD領域
   - ホイール
   - MENU / 選択 / 生成ボタン
3. 完全一致は目指さない
4. ただし以下はPNGに寄せる
   - 全体比率
   - 色味
   - ホイール位置
   - LCD位置
   - ボタン配置
5. 操作反応を優先する
   - タップでHUD/状態変化
   - MENUでスロット切替
   - ホイールで何らかの選択変化
6. 既存の `WheelViewModel` / `MemoryCard` をどう扱うかは再検討
7. 外部ライブラリ追加はしない
8. MusicKit / 音楽ファイル / haptic / tick音 / Boot接続はまだしない

---

## 9. 触ってはいけないもの・注意点

引き続き以下は勝手に触らない。

```text
MusicKit本実装
音楽ファイル利用
haptic
tick音
Boot画面
Home/Moments/Detail/Playing接続
外部ライブラリ追加
課金・広告
App Store / TestFlight
正式アプリ名決定
```

MacでXcodeを開くと、以下が変更される可能性がある。

```text
WheelPrototype.xcodeproj/project.pbxproj
WheelPrototype.xcodeproj/xcshareddata/xcschemes/WheelPrototype.xcscheme
WheelPrototype.xcodeproj/project.xcworkspace/
```

確認後は必要に応じて戻す。

```bash
git restore WheelPrototype.xcodeproj/project.pbxproj
git restore WheelPrototype.xcodeproj/xcshareddata/xcschemes/WheelPrototype.xcscheme
rm -rf WheelPrototype.xcodeproj/project.xcworkspace/
git status
```

---

## 10. 次AIへの重要メモ

ユーザーの現在の判断:

- 参照PNGの見た目は良い
- ただし画像ベース実装は「ただの画像」に見え、アプリとして弱い
- SwiftUI方式に戻す必要を感じている
- ただし、見た目がダサくなる問題を避けたい
- 次は「参照PNGをデザイン正本にしつつ、SwiftUIで操作できるUIを作る」方向で整理したい

最重要:

```text
次は透明ヒット領域の調整を続けない。
画像ベースMVPを本線にしない。
参照PNGをデザイン仕様として使い、SwiftUI構成UIへ戻す方針を検討する。
```

---

## 11. 推奨git message

今回の画像ベースMVP実装はすでに以下でcommit済み。

```text
feat: add image-based memory tuner shell
```

もしDEBUG HUD / ヒット領域修正をcommitする場合の候補:

```text
debug: add visible hit areas for image shell
```

ただし、この方向は本線から外れる可能性があるため、次セッションで `git status` を見て、commitするかrevertするか判断する。

