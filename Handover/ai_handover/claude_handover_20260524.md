# Claude Handover — 2026-05-24

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

### ドキュメント更新
- `_docs/SYSTEM_CURRENT.md`：Phase 3進行中・MemoryCard実装済み・コミット番号を反映
- `_docs/roadmapforAI.md`：Phase 1〜2完了・Phase 3進行中・完了項目を [x] に更新
- `_specs/wheel_spec_v0.md`：§4・§14 改訂（先頭↔末尾ループをサトシ判断として許容・無限スクロール感・飛びすぎ禁止・1ノッチ選択感維持は継続）

### 設計ドキュメント新規作成
- `_specs/memory_card_spec_v0.md`：MemoryCardの構造・表示・体験上の役割を定義
- `_specs/cursor_impl_wheel_v0.md`：ホイールUI基本動作のCursor向け実装指示書
- `_specs/cursor_impl_xcode_project_v0.md`：Xcodeプロジェクト作成・WheelView接続のCursor向け実装指示書
- `_specs/cursor_impl_memory_card_v0.md`：MemoryCard表示・ループ実装のCursor向け実装指示書
- `_specs/cursor_impl_docs_update_v0.md`：ドキュメント更新のCursor向け実装指示書
- `_design/previews/wheel_memory_card_preview_v0.html`：WheelView静止画プレビュー（サトシ承認済み）

### 実装（Cursorが実施・Claudeが指示書作成）
- `src/Models/MemoryCard.swift`：新規作成（3行固定・日本語モック7枚）
- `src/Models/WheelItem.swift`：削除（MemoryCardに置き換え）
- `src/ViewModels/WheelViewModel.swift`：MemoryCard対応・端ループ実装
- `src/Views/WheelView.swift`：MemoryCard 3行表示対応
- `App/WheelPrototypeApp.swift`：新規作成
- `App/ContentView.swift`：新規作成
- `WheelPrototype.xcodeproj/`：新規作成

### Git（このセッションのコミット）
| コミット | 内容 |
|---|---|
| fa8c331 | docs: update wheel loop direction after simulator test |
| d0bb2b5 | specs/preview 3ファイル追加 |
| 972e470 | MemoryCard実装本体 |
| 1c2abc8 | memory_card_spec §4-2 に合わせて line1/.title・line2/3/.callout 調整 |
| 2c54eb1 | docs: sync documents with MemoryCard implementation |

**最新コミット：2c54eb1**  
**origin/master と同期済み・working tree clean**

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
App/WheelPrototypeApp.swift
App/ContentView.swift
WheelPrototype.xcodeproj/
```

### 正本ファイル（変更にはサトシ承認が必要）
```
_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
README.md
AGENTS.md
```

---

## 3. 確定済みの技術・仕様

- iOS専用・SwiftUI中心・必要時のみUIKit補助
- MVPはモック再生（MusicKit将来受け口のみ）
- Xcodeプロジェクト名：WheelPrototype（動作確認用仮称）
- ノッチ角：30°（チューニング定数として分離済み）
- 慣性：easeOut(duration: 0.26)
- 端ループ：先頭↔末尾（サトシ判断済み・wheel_spec §4 改訂済み）
- MemoryCard：3行固定（line1/line2/line3）・日本語モック7枚

---

## 4. 次にやること（未着手）

以下の順で未着手。次の優先順位はサトシが判断する。

- [ ] ノッチ角・慣性のチューニング（実機メモ：30°はやや軽い）
- [ ] haptic / tick音の導入（サトシ判断事項）
- [ ] Boot画面の実装
- [ ] Momentsの選択画面の実装
- [ ] 記憶ナレーション表示
- [ ] モック再生との接続
- [ ] 1つ目の象徴的な演出

**補足**：セッション終了直前にサトシから「UIについてもう少し思っていることがある」との発言あり。次セッション冒頭でサトシにUIの意図を確認してから作業に入ること。

---

## 5. 触ってはいけないもの

- `_docs/SYSTEM_CORE.md`（不変の原則）
- `_docs/COLLABORATION_PROTOCOL.md`（不変の原則）
- MusicKit・音楽ファイル・haptic・tick音（別タスク・サトシ判断）
- アプリ名・ブランド名（サトシ判断事項）
- 課金・広告・配布方針（サトシ判断事項）
- 外部ライブラリ（サトシ承認なし不可）
- `AGENTS.md`（古い記載が残っているが、別タスクで対応予定）

---

## 6. 未確定のまま残っていること

- アプリ名
- MusicKit本格採用可否
- 音楽再生の最終方式
- haptic / tick音の導入タイミング
- Boot画面・Moments画面の実装順
- 外部ライブラリ利用方針
- 課金・広告の有無
- App Store配布方針
- AGENTS.md の更新（別タスク予定）
- サトシが次セッションで話すUIについての意図（未確認）

---

## 7. やらなかったこと（意図的な除外）

- ノッチ角チューニング：実機確認後にサトシが判断するため着手しなかった
- haptic / tick音：サトシ判断事項のため着手しなかった
- Boot画面・Moments画面：UIについてサトシの意図を次セッションで確認してから進める
- AGENTS.md更新：別タスクとして分離した
- アプリ名の決定：サトシ判断事項のため提案にとどめた

---

## 8. 既知の警告・注意

- Gitコミット時にLF→CRLF警告が出るが、Windows環境起因のため無視してよい
- シミュレータ確認はMac必要。Windowsでは静止画HTMLプレビューで代替する運用を確立済み
- `_design/previews/wheel_memory_card_preview_v0.html` がUI確認の基準となる静止画
