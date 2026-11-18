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
    }

    private(set) var state: State = .loading
    private(set) var shops: [Shop] = []
    private(set) var totalCount = 0
    /// 距離の計算に使う
    private(set) var currentLocation: CLLocation?

    let condition: SearchCondition
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
            state = shops.isEmpty ? .empty : .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
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
