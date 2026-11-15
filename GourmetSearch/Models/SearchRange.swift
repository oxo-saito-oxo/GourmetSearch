import Foundation

/// 現在地からの検索半径
/// ホットペッパーAPIの range パラメータ（1〜5）に対応している
enum SearchRange: Int, CaseIterable, Identifiable {
    case m300 = 1
    case m500 = 2
    case m1000 = 3
    case m2000 = 4
    case m3000 = 5

    var id: Int { rawValue }

    /// 半径（メートル）
    var meters: Int {
        switch self {
        case .m300: return 300
        case .m500: return 500
        case .m1000: return 1000
        case .m2000: return 2000
        case .m3000: return 3000
        }
    }

    /// 画面に出す文字（例: "300m", "1km"）
    var label: String {
        meters < 1000 ? "\(meters)m" : "\(meters / 1000)km"
    }
}
