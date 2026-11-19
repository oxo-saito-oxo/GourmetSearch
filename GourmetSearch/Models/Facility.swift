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

    /// 検索画面で使う名前
    var label: String {
        switch self {
        case .privateRoom: return "個室あり"
        case .freeDrink: return "飲み放題"
        case .freeFood: return "食べ放題"
        case .midnight: return "深夜営業"
        case .parking: return "駐車場あり"
        }
    }

    /// 詳細画面で使う短い名前
    var shortLabel: String {
        switch self {
        case .privateRoom: return "個室"
        case .freeDrink: return "飲み放題"
        case .freeFood: return "食べ放題"
        case .midnight: return "深夜営業"
        case .parking: return "駐車場"
        }
    }

    /// そのお店にこの設備・サービスがあるか
    func isAvailable(at shop: Shop) -> Bool {
        let value: String?
        switch self {
        case .privateRoom: value = shop.privateRoom
        case .freeDrink: value = shop.freeDrink
        case .freeFood: value = shop.freeFood
        case .midnight: value = shop.midnight
        case .parking: value = shop.parking
        }
        guard let value else { return false }
        return value.hasPrefix("あり") || value.hasPrefix("営業している")
    }
}
