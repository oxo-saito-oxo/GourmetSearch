import Foundation

/// 検索画面で選んだ条件のまとめ
struct SearchCondition: Hashable {
    let range: SearchRange
    let genre: GenreOption
    let facilities: Set<Facility>
}
