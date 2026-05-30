# Claude Handover — 2026-05-30

## AIへの指示（必須）
作業開始時に以下を順番に読むこと。
1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`
4. `_docs/roadmapforAI.md`
5. このHandoverファイル

読み終えるまで実装を開始しない。

---

## 1. このセッションで完了したこと

### UI方針の決定（サトシ確認済み）
- 白背景・簡易Web風UIを破棄
- ビジュアル方針を「アイボリー/白筐体 × 暗緑LCD × 黒いホイール」に確定
- インタラクティブHTMLプレビューをv1〜v3まで作成・サトシが確認・方向確定
- アプリ名「HAIKU TOUCH」がweb版プロトタイプに登場（確定かどうかはサトシ未明言）

### スロット構成の決定（サトシ確認済み）
- MemoryCardの1枚固定カードから、独立スロット操作方式に変更
- スロット：年 / 季節 / 天気 / 場所 / 情景（YEAR/SEASON/WEATHER/PLACE/SCENE）
- ホイール1つ・MENUボタンでアクティブスロットを切替
- 順序：YEAR → SEASON → WEATHER → PLACE → SCENE → ループ

### 作成ドキュメント（_specs/・_design/ に配置済み）
- `_specs/slot_wheel_spec_v0.md`：スロット切替ホイール仕様
- `_specs/ui_direction_v1.md`：新ビジュアル方針（※_design/ではなく_specs/に配置）
- `_specs/cursor_impl_visual_v1.md`：Cursor向けビジュアル変更実装指示書

### 実装（Cursorが実施）
- `src/Views/MemoryTunerView.swift`：SwiftUI見た目移植第一段階完了
- web版UIプロトタイプ（Next.js + Tailwind + TypeScript）：`web/` に作成済み
- 採用視覚基準：`_design/figma_exports/retro_device_black_wheel_v1/`

### Git
- 最新コミット：18a6baf
- origin/master 同期済み・working tree clean

---

## 2. 現在のバージョン・状態

| Phase | 状態 |
|---|---|
| Phase 0 初期ドキュメント整備 | 完了 |
| Phase 1 MVP体験設計 | 完了 |
| Phase 2 技術方向 | 完了 |
| Phase 3 プロトタイプ実装 | 進行中 |

### 実装済みファイル
```
src/Models/MemoryCard.swift
src/ViewModels/WheelViewModel.swift
src/Views/WheelView.swift
src/Views/MemoryTunerView.swift   ← 今セッションで追加
App/WheelPrototypeApp.swift
App/ContentView.swift
WheelPrototype.xcodeproj/
web/                              ← web版UIプロトタイプ
```

---

## 3. 次にやること

優先順位順：

1. **Mac / Xcode / iOSシミュレーターでビルド・表示確認**（未実施）
   - `MemoryTunerView.swift` が正しく表示されるか確認
   - ビルドエラーがあればCursorで修正

2. **スロット切替ロジックの実装**（未実施）
   - `slot_wheel_spec_v0.md` に基づき、MENUボタンでアクティブスロットを切替
   - ホイール操作でアクティブスロットの値だけ変わる動作
   - Cursor向け実装指示書が必要（Claudeが作成する）

3. **ノッチ角・慣性のチューニング**（実機確認後）

---

## 4. 触ってはいけないもの

- `_docs/SYSTEM_CORE.md`（不変の原則）
- `_docs/COLLABORATION_PROTOCOL.md`（不変の原則）
- MusicKit・音楽ファイル・haptic・tick音（別タスク・サトシ判断）
- 課金・広告・配布方針（サトシ判断）
- 外部ライブラリ（サトシ承認なし不可）

---

## 5. 未確定のまま残っていること

- アプリ名（「HAIKU TOUCH」はweb版に登場しているが正式確定かどうか不明）
- スロットの値リスト最終確定（現状はモック値）
- MusicKit本格採用可否
- haptic / tick音の導入タイミング
- Boot画面・Moments画面の実装順
- VT323フォントの採用可否（現状はmonospaced代替）
- 外部ライブラリ利用方針
- 課金・広告の有無
- App Store配布方針

---

## 6. やらなかったこと（意図的な除外）

- スロット切替ロジックの実装：ビジュアル確認を先にするため
- ビルド確認：Macが必要なため、サトシ側での実施待ち
- アプリ名の確定：サトシ判断事項のため
- Boot画面・Moments画面：現フェーズのスコープ外
