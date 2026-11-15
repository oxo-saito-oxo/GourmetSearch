import Foundation

// MARK: - エラー

/// 通信まわりで起きうるエラー
enum HotPepperAPIError: LocalizedError {
    /// Info.plist から APIキーが読めなかった（Secrets.xcconfig の設定漏れ）
    case missingAPIKey
    /// URLが組み立てられなかった
    case invalidURL
    /// HTTPのステータスコードが200番台ではなかった
    case badStatus(Int)
    /// APIがエラーを返した（キーが間違っている など）
    case apiError(message: String)
    /// JSONの読み込みに失敗した
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "APIキーが設定されていません。"
        case .invalidURL:
            return "リクエストの作成に失敗しました。"
        case .badStatus(let code):
            return "通信に失敗しました（ステータスコード: \(code)）。"
        case .apiError(let message):
            return "検索に失敗しました: \(message)"
        case .decodingFailed:
            return "データの読み込みに失敗しました。"
        }
    }
}

/// APIがエラーを返したときのJSON
/// { "results": { "error": [ { "message": "...", "code": 2000 } ] } }
private struct ErrorResponse: Decodable {
    let results: Body
    struct Body: Decodable {
        let error: [Item]
    }
    struct Item: Decodable {
        let message: String
        let code: Int
    }
}

// MARK: - プロトコル（差し替えられるようにするための約束事）

/// お店を検索する機能の約束事
/// 画面側（ViewModel）はこのプロトコルだけを知っていればよいので、
/// テストやプレビューでは本物の通信の代わりにダミーを渡せる
protocol ShopSearching {
    /// 現在地の周辺のお店を検索する
    func searchShops(
        latitude: Double,
        longitude: Double,
        range: SearchRange,
        page: Int,
        genreCode: String?
    ) async throws -> SearchResults

    /// IDを指定してお店を1件取得する
    func fetchShop(id: String) async throws -> Shop?
}

// MARK: - 本物の通信を行うクライアント

struct HotPepperAPIClient: ShopSearching {
    /// 1ページあたりの件数（APIの上限は100）
    static let pageSize = 20

    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let session: URLSession

    /// session を外から渡せるようにしておくと、テストで差し替えられる
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: 公開メソッド

    func searchShops(
        latitude: Double,
        longitude: Double,
        range: SearchRange,
        page: Int = 1,
        genreCode: String? = nil
    ) async throws -> SearchResults {
        // page（1, 2, 3...）を start（1, 21, 41...）に変換する
        let start = (page - 1) * Self.pageSize + 1

        var queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "range", value: String(range.rawValue)),
            URLQueryItem(name: "start", value: String(start)),
            URLQueryItem(name: "count", value: String(Self.pageSize)),
        ]
        if let genreCode {
            queryItems.append(URLQueryItem(name: "genre", value: genreCode))
        }

        return try await request(queryItems: queryItems)
    }

    func fetchShop(id: String) async throws -> Shop? {
        let results = try await request(queryItems: [
            URLQueryItem(name: "id", value: id)
        ])
        return results.shop.first
    }

    // MARK: 内部の処理

    /// APIキーを Info.plist から読み出す
    /// （Secrets.xcconfig → ビルド設定 → Info.plist の順で埋め込まれている）
    private func apiKey() throws -> String {
        guard
            let key = Bundle.main.object(forInfoDictionaryKey: "HotPepperAPIKey") as? String,
            !key.isEmpty,
            !key.hasPrefix("$(")   // xcconfig が割り当てられていないと "$(HOTPEPPER_API_KEY)" のまま残る
        else {
            throw HotPepperAPIError.missingAPIKey
        }
        return key
    }

    /// 共通の通信処理：URLを組み立てて、通信して、JSONを読み込む
    private func request(queryItems: [URLQueryItem]) async throws -> SearchResults {
        // 1. URLを組み立てる（キーと format=json はどのリクエストにも必要）
        guard var components = URLComponents(string: baseURL) else {
            throw HotPepperAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "key", value: try apiKey()),
            URLQueryItem(name: "format", value: "json"),
        ] + queryItems

        guard let url = components.url else {
            throw HotPepperAPIError.invalidURL
        }

        // 2. 通信する
        let (data, response) = try await session.data(from: url)

        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw HotPepperAPIError.badStatus(http.statusCode)
        }

        // 3. JSONを読み込む
        let decoder = JSONDecoder()
        // results_available → resultsAvailable のように、スネークケースをキャメルケースに自動変換する
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(HotPepperResponse.self, from: data).results
        } catch {
            // 正常な形で読めなかったら、APIのエラー応答かどうかを確かめる
            if let apiError = try? decoder.decode(ErrorResponse.self, from: data),
               let first = apiError.results.error.first {
                throw HotPepperAPIError.apiError(message: first.message)
            }
            throw HotPepperAPIError.decodingFailed(error)
        }
    }
}
