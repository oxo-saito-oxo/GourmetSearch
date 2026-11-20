import CoreLocation
import Observation

/// 一覧画面のデータと処理を担当する
@MainActor
@Observable
final class ShopListViewModel {
    /// 画面の状態
    enum State {
        case loading
        case loaded
        case empty
        case error(String)
        case locationDenied
    }

    private(set) var state: State = .loading
    private(set) var shops: [Shop] = []
    private(set) var totalCount = 0
    /// 距離の計算に使う
    private(set) var currentLocation: CLLocation?
    /// 次のページがあるか
    private(set) var hasNextPage = false
    /// 次のページを読み込み中か
    private(set) var isLoadingMore = false
    /// 今どのページまで読み込んだか
    private var currentPage = 1

    private(set) var condition: SearchCondition
    private let searcher: ShopSearching
    private let locationManager: LocationManager

    init(
        condition: SearchCondition,
        searcher: ShopSearching? = nil,
        locationManager: LocationManager? = nil
    ) {
        self.condition = condition
        self.searcher = searcher ?? HotPepperAPIClient()
        self.locationManager = locationManager ?? LocationManager()
    }

    /// 現在地を取って、1ページ目を検索する
    func load() async {
        state = .loading
        do {
            let location = try await locationManager.requestLocation()
            currentLocation = location

            let results = try await searcher.searchShops(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                range: condition.range,
                page: 1,
                genreCode: condition.genre.code,
                facilities: condition.facilities
            )
            shops = results.shop
            totalCount = results.resultsAvailable
            currentPage = 1
            hasNextPage = results.hasNextPage
            state = shops.isEmpty ? .empty : .loaded
        } catch LocationError.denied {
            state = .locationDenied
        } catch is URLError {
            state = .error("インターネットに接続できませんでした。通信環境を確認して、もう一度お試しください。")
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// 次のページを読み込んで、一覧の後ろに足す
    func loadMore() async {
        guard hasNextPage, !isLoadingMore, let location = currentLocation else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let results = try await searcher.searchShops(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                range: condition.range,
                page: currentPage + 1,
                genreCode: condition.genre.code,
                facilities: condition.facilities
            )
            currentPage += 1
            let existingIDs = Set(shops.map(\.id))
            shops.append(contentsOf: results.shop.filter { !existingIDs.contains($0.id) })
            hasNextPage = results.hasNextPage
        } catch {
            // 追加の読み込みに失敗しても、表示中の一覧は消さない
            // （もう一度下までスクロールすれば再挑戦される）
        }
    }

    /// 距離を1段階広げて検索し直す
    func widenRange() async {
        guard let next = condition.range.next else { return }
        condition = SearchCondition(
            range: next,
            genre: condition.genre,
            facilities: condition.facilities
        )
        await load()
    }

    /// 現在地からお店までの距離を「120m」「1.2km」の形で返す
    func distanceText(for shop: Shop) -> String? {
        guard let currentLocation else { return nil }
        let shopLocation = CLLocation(latitude: shop.lat, longitude: shop.lng)
        let meters = currentLocation.distance(from: shopLocation)
        if meters < 1000 {
            return "\(Int((meters / 10).rounded()) * 10)m"
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
    }
}
