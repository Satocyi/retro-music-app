import Foundation

/// ホイール1行ぶんの表示用モデル（音楽ファイル・MusicKitは扱わない）
struct WheelItem: Identifiable, Equatable {
    let id: UUID
    let title: String
}

/// 開発用モックデータ（指示書§3-1: 5〜10件）
enum WheelMockData {
    static let items: [WheelItem] = [
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000001")!, title: "Late Night Drive"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000002")!, title: "1998 Summer"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000003")!, title: "Rain on Metal"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000004")!, title: "Basement Mix"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000005")!, title: "Slow Walk Home"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000006")!, title: "Static FM"),
        WheelItem(id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000007")!, title: "City Edge"),
    ]
}
