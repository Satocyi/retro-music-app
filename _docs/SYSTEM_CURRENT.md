# SYSTEM_CURRENT

この文書は、このアプリ開発プロジェクトの「現在地」を記録するファイルです。
推測・願望・未確定案は書かず、現時点で確定している事実のみを書く。

---

## 0. 現在の状態

- Phase 1「MVP体験設計」進行中・核設計まで完了
- 実装は未開始
- アプリ名は未確定
- MVP範囲：核設計まで完了。実装範囲は未確定
- 技術方向：正式採用済み（tech_direction_v0.md）
- 詳細技術実装：未確定
- 外部ライブラリ利用方針：未確定
- 対象OS：iOS専用で開始
- MVPの音楽再生：モックから開始する（最終方式は未確定）
- MusicKit：将来連携の受け口のみを設計で考慮する。本格採用は未確定（採用確定ではない）

---

## 1. 現時点で作成済みのフォルダ

_docs/
Handover/ai_handover/
_design/
_specs/
_prompts/
_archive/
src/

---

## 2. 現時点で作成済みの正本ファイル

_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
README.md
AGENTS.md

## 3. 現時点で作成済みの設計ファイル

_design/ui_concept.md
_design/reference_direction.md
_specs/mvp_flow_v0.md
_specs/wheel_spec_v0.md
_specs/tech_direction_v0.md

---

## 4. 確定済みの開発方針

このアプリは、単なる音楽再生アプリではなく、昔のデジタル音楽体験を現代スマートフォン上で再構成するアプリである

便利さよりも、懐かしさ・手触り・偶然性・小さな発見を重視する

MVPでは、機能数より「触った瞬間に面白い体験」を優先する

複数AIを使う場合は、役割を分けて進める

大きな変更は1ステップずつ進める

---

## 5. 正式採用済みの技術方向

以下はtech_direction_v0.mdに基づく正式採用済みの技術方向。
詳細実装は未確定。

- 対象OS：iOS専用で開始
- UIフレームワーク：SwiftUI中心、必要時のみUIKit補助
- 音楽再生：MVPではモック再生
- MusicKit：将来連携の受け口のみ設計段階で考慮する。本格採用は未確定（採用確定ではない）
- Android：後回し
- 優先品質：触感・haptic・音の品質をUIの完成度より優先する

---

## 6. 未確定事項

アプリ名
MusicKit本格採用可否
音楽再生の最終方式
UIの具体実装
MVP実装範囲の確定
外部ライブラリ利用方針
課金・広告の有無
外部API利用の有無
App Store配布方針

---

## 7. 次に決めるべきこと

Phase 3（プロトタイプ実装）の開始準備
Cursor向け最初の実装指示書を作成する

---

## 8. AI作業開始時に読む順番

AIは作業開始時に以下の順で読む。

_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
Handover/ai_handover/ の最新handover
