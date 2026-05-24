# Cursor向け実装指示書 — ドキュメント更新 v0

**対象フェーズ**: Phase 3 プロトタイプ実装（MemoryCard実装後のドキュメント整合）  
**作成者**: Claude  
**作成日**: 2026-05-23  
**前提コミット**: 1c2abc8（MemoryCard実装・調整済み）  

---

## 0. この指示書を読む前に

作業開始前に以下を順番に読むこと。読み終えるまで変更を開始しない。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`（現在の記載内容を把握する）
4. `_docs/roadmapforAI.md`（現在のチェック状態を把握する）
5. この指示書

---

## 1. このタスクの目的

MemoryCard実装（1c2abc8）によって生じた、正本ドキュメントと実装の乖離を解消する。

**コードは一切変更しない。ドキュメントのみ更新する。**

---

## 2. 作業対象ファイル

### 変更するファイル

```
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
```

### 変更してはいけないファイル

```
_docs/SYSTEM_CORE.md           （不変の原則）
_docs/COLLABORATION_PROTOCOL.md（不変の原則）
_specs/ 配下の全ファイル
README.md
AGENTS.md                  （今回スコープ外。別タスクで対応）
src/ 配下の全ファイル
App/ 配下の全ファイル
```

---

## 3. SYSTEM_CURRENT.md の変更内容

### §0「現在の状態」を以下に差し替える

```
- Phase 1「MVP体験設計」完了
- Phase 2「技術方向」完了
- Phase 3「プロトタイプ実装」進行中
- ホイールUI基本動作：実装済み・シミュレータ動作確認済み
- MemoryCard（3行・日本語）：実装済み・端ループ実装済み
- Xcodeプロジェクト：作成済み・ビルド成功・GitHub同期済み
- 最新コミット：1c2abc8
- アプリ名は未確定
- MVP範囲：核設計まで完了。実装範囲は未確定
- 技術方向：正式採用済み（tech_direction_v0.md）
- 詳細技術実装：未確定
- 外部ライブラリ利用方針：未確定
- 対象OS：iOS専用で開始
- MVPの音楽再生：モックから開始する（最終方式は未確定）
- MusicKit：将来連携の受け口のみを設計で考慮する。本格採用は未確定（採用確定ではない）
```

### §3「現時点で作成済みの設計ファイル」に以下を追加する

```
_specs/memory_card_spec_v0.md
_specs/cursor_impl_memory_card_v0.md
_design/previews/wheel_memory_card_preview_v0.html
```

### §4「現時点で作成済みの実装ファイル」を以下に差し替える

```
src/Models/MemoryCard.swift        （WheelItem.swift から置き換え）
src/ViewModels/WheelViewModel.swift
src/Views/WheelView.swift
App/WheelPrototypeApp.swift
App/ContentView.swift
WheelPrototype.xcodeproj/
```

※ `src/Models/WheelItem.swift` は削除済みのため記載しない。

### §6「正式採用済みの技術方向」の最新コミット行を更新する

```
- 最新コミット：1c2abc8
```

### §8「次に決めるべきこと」を以下に差し替える

```
- ノッチ角・慣性のチューニング（実機メモ：30°はやや軽い）
- haptic / tick音の導入タイミングをサトシが判断する
- Boot画面・Moments画面の実装順をサトシが判断する
```

※「ホイールの端ループ仕様を実装する」は実装済みのため削除する。

---

## 4. roadmapforAI.md の変更内容

### §0「現在地」を以下に差し替える

```
- Phase 1「MVP体験設計」完了
- Phase 2「技術方向」完了
- Phase 3「プロトタイプ実装」進行中
- MemoryCard（3行・日本語・端ループ）：実装済み（1c2abc8）
```

### Phase 3 チェックボックスを以下に更新する

完了済みに `[x]` を付ける。未着手は `[ ]` のまま。

```
- [x] Cursor向け実装指示書を作成する（cursor_impl_wheel_v0.md）
- [x] ホイールUIの基本動作を作る（src/ 配下3ファイル）
- [x] 実機またはシミュレータで動作確認する（シミュレータ確認済み・48ef42b）
- [x] ホイールの端ループ仕様を実装する（1c2abc8・サトシ判断済み）
- [x] WheelItem → MemoryCard（3行・日本語）への置き換え（1c2abc8）
- [ ] ノッチ角・慣性のチューニング（実機メモ：30°はやや軽い）
- [ ] haptic / tick音の導入判断（サトシ判断事項）
- [ ] 起動画面を作る（Boot演出）
- [ ] Momentsの選択画面を作る
- [ ] 記憶ナレーション表示を作る
- [ ] モック再生を繋ぐ
- [ ] 1つ目の象徴的な演出を入れる
```

---

## 5. 禁止事項

| 禁止 | 理由 |
|---|---|
| `src/` 配下のコード変更 | このタスクはドキュメントのみ |
| `SYSTEM_CORE.md` の変更 | 不変の原則 |
| `COLLABORATION_PROTOCOL.md` の変更 | 不変の原則 |
| `_specs/` 配下の変更 | このタスクのスコープ外 |
| `README.md` の変更 | サトシ承認なし不可 |
| `AGENTS.md` の変更 | 今回スコープ外。別タスクで対応 |
| 推測・願望を正本ファイルに書く | SYSTEM_CURRENT の原則 |
| 未確定事項を確定として書く | 同上 |

---

## 6. チェックリスト

### 変更確認

- [ ] `SYSTEM_CURRENT.md` §0 のコミット番号が `1c2abc8` になっている
- [ ] `SYSTEM_CURRENT.md` §4 に `WheelItem.swift` が残っていない
- [ ] `SYSTEM_CURRENT.md` §4 に `MemoryCard.swift` が記載されている
- [ ] `SYSTEM_CURRENT.md` §3 に `memory_card_spec_v0.md` が記載されている
- [ ] `SYSTEM_CURRENT.md` §8 に「端ループ実装」が残っていない（実装済みのため）
- [ ] `roadmapforAI.md` の端ループ・MemoryCard置き換えが `[x]` になっている
- [ ] コード変更が0件である（`src/` `App/` に手を付けていない）
- [ ] 正本ファイル（`SYSTEM_CORE.md` / `COLLABORATION_PROTOCOL.md`）を変更していない

### コミット

変更後、以下のメッセージでコミットする。

```
docs: sync documents with MemoryCard implementation (1c2abc8)
```

---

## 7. 完了後にやること

1. §6 チェックリストを全て確認する
2. `git push` を実行する（origin との同期）
3. サトシに完了を報告する

---

## 変更履歴

| 日付 | 内容 |
|------|------|
| 2026-05-23 | v0 初版（Claude作成） |
