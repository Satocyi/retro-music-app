# SYSTEM_CURRENT

この文書は、このアプリ開発プロジェクトの「現在地」を記録するファイルです。
推測・願望・未確定案は書かず、現時点で確定している事実のみを書く。

---

## 0. 現在の状態

- Phase 1「旧MVP体験設計（音楽）」は終了
- Phase 2「旧技術方向（音楽）」は終了
- 方針転換：音楽アプリから写真チューニングアプリへピボット
- 新方針：iPhone写真を、ホイール操作で「記憶の空気」に変換するレトロデバイス型アプリ
- 音楽連携：本線から外す
- MusicKit / Spotify / 音楽ファイル / 音楽再生：今後の本線では扱わない
- 現在の黒ホイールUI：写真チューニング操作盤として継続利用する
- web版UI検証プロトタイプ：作成済み
- SwiftUI見た目移植第一段階：完了
- Mac / Xcode / iOSシミュレーターでのビルド確認：未実施
- 初期MVP方針：AI画像生成APIを使わず、iPhone内処理の写真フィルターで確認する
- AI画像変換API：後続検証対象
- アプリ名：未確定
- 写真データ保存方針：未確定
- 課金・広告：未確定
- App Store配布方針：未確定

---

## 1. 現時点で作成済みのフォルダ

_docs/
Handover/ai_handover/
_design/
_design/figma_exports/retro_device_black_wheel_v1/
_specs/
_prompts/
_archive/
src/
App/
web/

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
_specs/memory_card_spec_v0.md
_specs/cursor_impl_memory_card_v0.md
_design/previews/wheel_memory_card_preview_v0.html
_design/figma_exports/retro_device_black_wheel_v1/   （Figma黒ホイール版・採用視覚基準）

※ 上記設計ファイルの多くは旧方針（音楽）前提で作成されたもの。Phase 0 で整理予定。

## 4. 現時点で作成済みの実装ファイル

### SwiftUI（iOS）

src/Models/MemoryCard.swift        （WheelItem.swift から置き換え）
src/ViewModels/WheelViewModel.swift
src/Views/WheelView.swift
src/Views/MemoryTunerView.swift   （web版黒ホイールUI基準・見た目移植第一段階）
App/WheelPrototypeApp.swift
App/ContentView.swift
WheelPrototype.xcodeproj/

### web（UI検証プロトタイプ）

web/                               （Next.js + Tailwind + TypeScript・黒ホイール版レトロデバイスUI・ビルド成功）
※ SwiftUI見た目移植第一段階は完了。操作感の作り込みは未実施

---

## 5. 確定済みの開発方針

昔の携帯デジタル機器の手触りを借りて、iPhone写真を「記憶の空気」に変換する体験を作る

単なる写真フィルターアプリではない。写真を速く加工するアプリでもない

便利さよりも、懐かしさ・手触り・偶然性・小さな発見を重視する

MVPでは、機能数より「触った瞬間に面白い体験」を優先する

初期MVPではAI画像生成APIを使わず、iPhone内処理の写真フィルターで確認する

複数AIを使う場合は、役割を分けて進める

大きな変更は1ステップずつ進める

---

## 6. 正式採用済みの技術方向

以下は現時点で確定している技術方向。詳細実装は未確定。

- 対象OS：iOS専用で開始
- UIフレームワーク：SwiftUI中心、必要時のみUIKit補助
- 写真入力：カメラ撮影 / フォトライブラリ読み込みを検討
- 初期画像処理：iPhone内処理の写真フィルターを優先
- AI画像生成API：初期MVPでは使わない
- 外部API：未確定。採用にはサトシ判断が必要
- ユーザー写真のサーバー送信：未確定。採用にはサトシ判断が必要
- Android：後回し
- Xcodeプロジェクト名：WheelPrototype（動作確認用仮称）
- web版UI検証：Next.js + Tailwind + TypeScript（`web/`）で黒ホイール版UIを表示・ビルド成功
- 採用視覚基準：Figma黒ホイール版（`_design/figma_exports/retro_device_black_wheel_v1/`）
- SwiftUI見た目移植第一段階：完了（`src/Views/MemoryTunerView.swift`）
- SwiftUI操作感の作り込み：未実施
- Mac / Xcode / iOSシミュレーターでのビルド確認：未実施

---

## 7. 未確定事項

アプリ名
写真入力方法
写真保存方法
写真データ保存方針
ユーザー写真のサーバー送信有無
AI画像生成API採用可否
課金・広告の有無
App Store配布方針
フィルターの初期プリセット
ホイールで調整する項目

---

## 8. 次に決めるべきこと

- 写真アプリとしてのMVP体験を確定する
- 写真入力方法を決める（カメラ / フォトライブラリ）
- ホイールで調整する項目を決める
- 初期フィルターのプリセットを決める
- AI画像生成APIを使わない範囲でMVPを設計する

---

## 9. AI作業開始時に読む順番

AIは作業開始時に以下の順で読む。

_docs/SYSTEM_CORE.md
_docs/COLLABORATION_PROTOCOL.md
_docs/SYSTEM_CURRENT.md
_docs/roadmapforAI.md
Handover/ai_handover/ の最新handover
