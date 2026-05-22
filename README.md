# Retro Music App

このプロジェクトは、昔のデジタル音楽体験を現代のスマートフォン上で再構成するアプリ開発プロジェクトです。

単なる音楽再生アプリではなく、レトロな操作感・偶然性・手触り・小さな演出を通じて、音楽を少し特別な体験として楽しむことを目的とします。

---

## AI作業開始時に読む順番

AIは作業開始時に、必ず以下の順番で読む。

1. `_docs/SYSTEM_CORE.md`
2. `_docs/COLLABORATION_PROTOCOL.md`
3. `_docs/SYSTEM_CURRENT.md`
4. `_docs/roadmapforAI.md`
5. `Handover/ai_handover/` の最新handover

---

## 現在のフェーズ

現在は **Phase 0: 初期ドキュメント整備**。

実装はまだ開始していない。  
MVP範囲・技術スタック・対象OSは未確定。

---

## フォルダ構成

```text
_docs/                … 正本ドキュメント
Handover/ai_handover/ … AIセッション引き継ぎ
_design/              … 体験設計・UI案
_specs/               … 仕様書
_prompts/             … AI用プロンプト
_archive/             … 退避・過去資料
src/                  … 実装コード
```

## 重要ファイル

| ファイル | 役割 |
| :--- | :--- |
| `_docs/SYSTEM_CORE.md` | 不変の原則 |
| `_docs/COLLABORATION_PROTOCOL.md` | AI作業ルール |
| `_docs/SYSTEM_CURRENT.md` | 現在地 |
| `_docs/roadmapforAI.md` | 今後の作業順 |
| `AGENTS.md` | Cursor / AIエージェント向け指示 |
| `README.md` | 人間とAIの入口 |

## 作業ルール

- 1ステップずつ進める
- 正本ファイルは勝手に変更しない
- 実装前に目的を確認する
- UXの核はAIが勝手に変えない
- 不明なことは推測せず「不明」とする
- Handoverには「何をやらなかったか」も記録する
