# SYSTEM_CURRENT

この文書は、このアプリ開発プロジェクトの「現在地」を記録するファイルです。
推測・願望・未確定案は書かず、現時点で確定している事実のみを書く。

---

## 0. 現在の状態

- Phase 1「MVP体験設計」完了
- Phase 2「技術方向」完了
- Phase 3「プロトタイプ実装」進行中
- ホイールUI基本動作：実装済み・シミュレータ動作確認済み
- Xcodeプロジェクト：作成済み・ビルド成功・GitHub同期済み（48ef42b）
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
App/

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
_specs/cursor_impl_wheel_v0.md
_specs/cursor_impl_xcode_project_v0.md

## 4. 現時点で作成済みの実装ファイル

src/Models/WheelItem.swift
src/ViewModels/WheelViewModel.swift
src/Views/WheelView.swift
App/WheelPrototypeApp.swift
App/ContentView.swift
WheelPrototype.xcodeproj/

---

## 5. 確定済みの開発方針

このアプリは、単なる音楽再生アプリではなく、昔のデジタル音楽体験を現代スマートフォン上で再構成するアプリである

便利さよりも、懐かしさ・手触り・偶然性・小さな発見を重視する

MVPでは、機能数より「触った瞬間に面白い体験」を優先する

複数AIを使う場合は、役割を分けて進める

大きな変更は1ステップずつ進める

---

## 6. 正式採用済みの技術方向

以下はtech_direction_v0.mdに基づく正式採用済みの技術方向。
詳細実装は未確定。

- 対象OS：iOS専用で開始
- UIフレームワーク：SwiftUI中心、必要時のみUIKit補助
- 音楽再生：MVPではモック再生
- MusicKit：将来連携の受け口のみ設計段階で考慮する。本格採用は未確定（採用確定ではない）
- Android：後回し
- 優先品質：触感・haptic・音の品質をUIの完成度より優先する
- Xcodeプロジェクト名：WheelPrototype（動作確認用仮称）
- 最新コミット：48ef42b

---

## 7. 未確定事項

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

## 8. 次に決めるべきこと

- ホイールの端ループ仕様を実装する（サトシ判断済み）
- ノッチ角・慣性のチューニング（実機メモ：30°はやや軽い）
- haptic / tick音の導入タイミングをサトシが判断する

---

## 9. AI作業開始時に読む順番

AIは作業開始時に以下の順で読む。

_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
Handover/ai_handover/ の最新handover
