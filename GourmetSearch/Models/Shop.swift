import Foundation

// MARK: - APIレスポンス全体

/// ホットペッパーグルメリサーチAPIのレスポンス全体
/// JSONは{ "result": {...} } という形なので、外側を1段被せている
struct HotPepperResponse: Decodable {
    let results: SearchResults
}

/// 検索結果(ページング情報 + お店の一覧)
struct SearchResults: Decodable {
    /// 条件に合うお店の総数
    let resultsAvailable: Int
    /// 今回返ってきた件数(APIの仕様上文字列で返ってくる)
    let resultsReturned: String
    /// 何件目から返ってきたか(1始まり)
    let resultsStart: Int
    /// お店の一覧
    let shop: [Shop]

    /// 次のページがあるかどうか
    var hasNextPage: Bool {
        let returned = Int(resultsReturned) ?? 0
        return resultsStart + returned - 1 < resultsAvailable
    }
}

// MARK: - お店

/// お店1件分の情報
/// アプリで使う項目だけを定義している(使わない項目はJSONにあっても無視される)
struct Shop: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let access: String
    let lat: Double
    let lng: Double
    let open: String
    let close: String
    let genre: Genre
    let budget: Budget
    let photo: Photo
    let urls: ShopURLs

    // 設備・条件(「あり」「なし:補足」のような文字列)
    //念のため、項目がない店があっても落ちないようにオプショナルにしている
    let privateRoom: String?
    let midnight: String?
    let freeDrink: String?
    let freeFood: String?
    let parking: String?
}

// MARK: - お店の中の入れ子項目

struct Genre: Decodable, Hashable {
    /// 絞り込み検索でAPIに渡すコード(例："G004")
    let code: String
    /// 表示用の名前(例："和食")
    let name: String
}

struct Budget: Decodable, Hashable {
    /// 予算の目安(例："2001~3000円")
    let name: String
}

struct Photo: Decodable, Hashable {
    let pc: PCPhoto
    let mobile: MobilePhoto

    struct PCPhoto: Decodable, Hashable {
        /// 238px。詳細画面の上部に使う
        let l: String
    }

    struct MobilePhoto: Decodable, Hashable {
        /// 100px。一覧のサムネイルに使う
        let s: String
    }
}

struct ShopURLs: Decodable, Hashable {
    /// ホットペッパーのお店のページ
    let pc: String
}

// MARK: - 画面で使いやすくするための便利プロパティ

extension Shop {
    /// 一覧のサムネイル画像のURL
    var thumbnailURL: URL? { URL(string: photo.mobile.s) }
    /// 詳細画面の上部に出す画像のURL
    var largeImageURL: URL? { URL(string: photo.pc.l) }
    /// ホットペッパーのページのURL
    var pageURL: URL? { URL(string: urls.pc) }
}
