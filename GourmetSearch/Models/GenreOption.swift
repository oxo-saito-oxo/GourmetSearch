import Foundation

/// 検索画面で選べるジャンル
struct GenreOption: Identifiable, Hashable {
    /// APIに渡すジャンルコード。nil は「すべて」
    let code: String?
    let name: String

    var id: String { code ?? "all" }

    static let all: [GenreOption] = [
        GenreOption(code: nil, name: "すべて"),
        GenreOption(code: "G001", name: "居酒屋"),
        GenreOption(code: "G004", name: "和食"),
        GenreOption(code: "G005", name: "洋食"),
        GenreOption(code: "G007", name: "中華"),
        GenreOption(code: "G008", name: "焼肉・ホルモン"),
        GenreOption(code: "G013", name: "ラーメン"),
        GenreOption(code: "G014", name: "カフェ・スイーツ"),
        GenreOption(code: "G006", name: "イタリアン・フレンチ"),
        GenreOption(code: "G017", name: "韓国料理"),
    ]
}

