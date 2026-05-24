# Cursor向け実装指示書 — ビジュアル変更 v1

**対象フェーズ**: Phase 3 プロトタイプ実装
**作成者**: Claude
**作成日**: 2026-05-24
**前提コミット**: 2c54eb1
**前提ドキュメント**: `_design/ui_direction_v1.md` / `_specs/wheel_spec_v0.md`

---

## 0. 作業開始前に読むこと

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_design/ui_direction_v1.md`（**全文精読。これが今回の正本**）
4. この指示書

---

## 1. このタスクの目的

現行の白背景・簡易Web風UIを破棄し、`ui_direction_v1.md` で定義した
**ピュアアイボリー筐体 × 暗緑LCD** のビジュアルに置き換える。

**ロジックは一切触らない。**
`WheelViewModel.swift` / `MemoryCard.swift` は変更しない。
変更対象は `WheelView.swift` と `ContentView.swift` のビジュアル部分のみ。

---

## 2. 変更対象ファイル

```
src/Views/WheelView.swift        ← メイン変更対象
App/ContentView.swift            ← 背景色のみ変更
```

### 変更してはいけないファイル

```
src/Models/MemoryCard.swift
src/ViewModels/WheelViewModel.swift
App/WheelPrototypeApp.swift
_docs/ 配下の全ファイル
_specs/ 配下の全ファイル
```

---

## 3. 実装仕様

### 3-1. アプリ背景

```swift
// ContentView.swift
// 背景色を黒に変更
Color(hex: "111113").ignoresSafeArea()
```

### 3-2. 筐体（デバイス本体）

| 要素 | 値 |
|---|---|
| 形状 | RoundedRectangle(cornerRadius: 26) |
| 背景グラデーション | LinearGradient: #eeeae2 → #e2ddd4 → #e8e3da（上→下、angle: 175°） |
| 外枠ボーダー | #c4bfb4、1px |
| 下辺ボーダー | #9e9a90、3px（押し込み感） |
| 影 | .shadow(color: .black.opacity(0.55), radius: 28, y: 14) |
| 上面ハイライト | 筐体上端に白寄りの1px highlight線 |

### 3-3. LCD パネル

| 要素 | 値 |
|---|---|
| 背景色 | #090b09 |
| 枠 | #141614、1px。下辺のみ#060806、2px |
| 角丸 | 5px |
| 内側影 | inset shadow、暗め |
| スキャンライン | Canvas または ZStack で横線を薄く重ねる（opacity 0.18〜0.22、ピッチ3px） |

#### スロット行（各行）

| 状態 | ラベル色 | 値テキスト色 | 背景 |
|---|---|---|---|
| 非アクティブ | #222420 | #2a2e26 | 透明 |
| アクティブ | #547840 | #94b86e | #0b110a |

- アクティブ行は左端に縦ライン（Color(hex:"486435")、幅2px）
- アクティブ値に `.shadow(color: Color(hex:"6ea046").opacity(0.45), radius: 4)`
- カーソル（▌）をアクティブ行の右端に点滅表示（`withAnimation(.easeInOut(duration:0.55).repeatForever())`）

#### フォント

| 用途 | フォント |
|---|---|
| スロットラベル（年/季節…） | カスタムまたは .caption2、細め、letter-spacing広め |
| スロット値（1994/春…） | VT323相当のmonospaced系、または .system(.title3, design: .monospaced) |

VT323はiOSカスタムフォントとして追加が必要。追加コストが高い場合は `.monospacedDigit()` で代替し、サトシに報告すること。

### 3-4. ホイール（リング）

| 要素 | 値 |
|---|---|
| 外周形状 | Circle() |
| 外周グラデーション | AngularGradient: #d4d0c8 → #e4e0d6 → #c8c4bc → #dedad0 … （ウォーム系でムラを表現） |
| 外周枠 | #b0aca4、1px。さらに外側に#9a9690、1px |
| 上面ハイライト | 上部にwhite.opacity(0.58)のthin arc |
| 下部シャドウ | 下部にblack.opacity(0.25)のthin arc |
| リング幅 | 外径の約17%（inset 14px相当） |
| 内側トラック | Circle()、#131514、inset shadow深め |
| ノッチ | 12個。30°間隔。3個に1個メジャー（高さ7px、通常5px）。色 #b0aba2 |

#### 方向インジケーター（上下左右の三角）

```swift
// 各方向に小さな三角形（7×7pt）
// 色: #a8a49e、opacity: 0.3
// アクティブ操作中は opacity: 0.55 に上げる
```

#### 中央ボタン

| 要素 | 値 |
|---|---|
| 形状 | Circle()、inset 40pt |
| 背景 | LinearGradient: #dedad0 → #cac6bc |
| 枠 | #b0aca2、1px。下辺相当に#969289、2px（.shadow で代替可） |
| ラベル | 「決定」、Orbitron相当またはmonospaced、6〜7pt、色 #8a8680 |
| タップ時 | scaleEffect(0.95)、影を縮小 |

### 3-5. ボタン群（下部3ボタン）

横に3つ並べる: **MENU** / **選択** / **生成 →**

| 要素 | 値 |
|---|---|
| 背景 | LinearGradient: #dedad0 → #cac6bc |
| 枠 | #b0aca2、1px |
| 下辺影（押し込み感） | .shadow(color:#969289, radius:0, y:2) |
| 文字色 | #808078 |
| 角丸 | 7pt |
| タップ時 | offset(y: 1)、影を縮小 |
| フォント | MENU → monospaced系 / 選択・生成 → Noto Sans JPまたはシステム日本語 |

### 3-6. ヘッダー・フッター

```
ヘッダー左: "MEMORY TUNER"  monospaced、8pt、#8a8680
ヘッダー右: ● STANDBY      ●は緑(#4e7a4e)、テキストは#a0998e、8pt
フッター中央: "MEM-01 · 記憶装置"  monospaced、7pt、#b0aca4
```

---

## 4. 実装しないこと

- ロジック変更（ViewModel・Model）
- VT323フォント追加が複雑な場合は代替フォントでよい（報告すること）
- haptic / tick音
- アニメーション追加（既存の慣性はそのまま維持）
- Boot画面・Moments画面
- 外部ライブラリの追加

---

## 5. 確認チェックリスト

実装後、シミュレータで以下を確認してから完了とする。

- [ ] 黒背景にアイボリー筐体が浮かび上がって見える
- [ ] LCD内が暗緑色で、アクティブ行が明るく光って見える
- [ ] 非アクティブ行が暗く落ちており、アクティブ行との差が一目でわかる
- [ ] カーソル（▌）がアクティブ行右端で点滅している
- [ ] ホイールをドラッグするとアクティブ行の値が切り替わる（ロジックは既存のまま）
- [ ] MENUボタンを押すとアクティブスロットが切り替わる（この時点ではまだ実装不要。ボタンが存在すればよい）
- [ ] ボタンを押すと沈み込む感触がある（scaleまたはoffset）
- [ ] 筐体全体がiPhone画面中央に収まっている

---

## 6. 完了後の作業

確認チェックリストを全項目通過したら：

1. `git add src/Views/WheelView.swift App/ContentView.swift`
2. `git commit -m "feat: apply ivory body visual to WheelView"`
3. サトシに報告（スクリーンショットまたはシミュレータ動画を添付）

---

## 変更履歴

| 日付 | 内容 |
|---|---|
| 2026-05-24 | v1 初版 |
