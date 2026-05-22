# AGENTS.md

このファイルは、Cursor / AIエージェント向けの作業指示です。
AIは作業開始時にこのファイルを確認し、勝手な設計判断や不要な実装を行わないこと。

---

## 1. 作業開始時に読む順番

必ず以下を読む。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`
4. `_docs/roadmapforAI.md`
5. `Handover/ai_handover/` の最新handover

読み終えるまで実装を開始しない。

---

## 2. 現在の状態

- このプロジェクトは初期ドキュメント整備中
- 実装はまだ開始していない
- MVP範囲は未確定
- 技術スタックは未確定
- 対象OSは未確定

---

## 3. 実装前のルール

以下を守る。

- いきなりコードを書かない
- まず目的と対象ファイルを確認する
- 正本ファイルを勝手に変更しない
- UXの核を勝手に変えない
- 外部ライブラリを勝手に追加しない
- 外部APIを勝手に使わない
- 音楽ファイルや著作権に関わる判断を勝手にしない

---

## 4. 正本ファイル

以下は正本ファイル。

```text
_docs/SYSTEM_CORE.md
_docs/SYSTEM_CURRENT.md
_docs/COLLABORATION_PROTOCOL.md
_docs/roadmapforAI.md
README.md
AGENTS.md
```

変更する場合は、サトシの明示承認が必要。

---

## 5. 触ってよい場所

実装開始後、通常の作業対象は以下。

```text
src/
_design/
_specs/
_prompts/
```

ただし、現時点ではまだ実装開始前のため、`src/` には勝手にファイルを追加しない。

---

## 6. Handover

セッション終了時、サトシに依頼された場合のみHandoverを作る。

保存先：

```text
Handover/ai_handover/
```

ファイル名：

```text
claude_handover_YYYYMMDD.md
chatgpt_handover_YYYYMMDD.md
```

Handoverには「何をやらなかったか」も必ず書く。

---

## 7. 判断が必要な変更

以下は必ず `【判断が必要】` としてサトシに確認する。

- アプリ名
- 対象OS
- 技術スタック
- UXの核
- 課金・広告
- 外部API
- 外部ライブラリ
- 音源・著作権・データ保存方針
- 配布方針

---

## 8. 作業原則

- 1ステップずつ進める
- 1回の作業で複数目的を混ぜない
- 不明点は推測しない
- 古いファイルを勝手に削除しない
- 実装より先に設計を確認する
- 迷ったらSYSTEM_COREに戻る
