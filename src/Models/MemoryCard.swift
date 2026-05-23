import Foundation

// MemoryCard.swift
// Phase 3 — MemoryCard表示実装
// 仕様: _specs/memory_card_spec_v0.md

struct MemoryCard: Identifiable {
    let id: UUID
    let line1: String // 年代・季節・時間帯
    let line2: String // 天気・場所・空気感
    let line3: String // 行動・記憶・場面
}

// MARK: - Mock Data

extension MemoryCard {
    /// MVP動作確認用モックデータ（7枚・日本語）
    /// 実際の音楽・著作物とは無関係。アプリ名を含まない。
    static let mockCards: [MemoryCard] = [
        MemoryCard(id: UUID(), line1: "2007年 夏", line2: "雨", line3: "高校帰り"),
        MemoryCard(id: UUID(), line1: "2011年 冬", line2: "深夜 1:12", line3: "ひとりの部屋"),
        MemoryCard(id: UUID(), line1: "1999年 秋", line2: "曇り", line3: "図書館の帰り道"),
        MemoryCard(id: UUID(), line1: "2003年 春", line2: "朝", line3: "始発電車"),
        MemoryCard(id: UUID(), line1: "2009年 夏", line2: "夕暮れ", line3: "友達の家"),
        MemoryCard(id: UUID(), line1: "2014年 冬", line2: "雪", line3: "アルバイトの帰り"),
        MemoryCard(id: UUID(), line1: "2006年 夏", line2: "夜", line3: "祭りの後"),
    ]
}
