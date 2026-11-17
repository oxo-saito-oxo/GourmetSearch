import Foundation

/// こだわり条件（設備・サービス）
/// rawValue は、APIに渡すパラメータ名
enum Facility: String, CaseIterable, Identifiable {
    case privateRoom = "private_room"
    case freeDrink = "free_drink"
    case freeFood = "free_food"
    case midnight = "midnight"
    case parking = "parking"

    var id: String { rawValue }

    /// 画面に出す名前
    var label: String {
        switch self {
        case .privateRoom: return "個室あり"
        case .freeDrink: return "飲み放題"
        case .freeFood: return "食べ放題"
        case .midnight: return "深夜営業"
        case .parking: return "駐車場あり"
        }
    }
}
