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

    private let condition: SearchCondition
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
}
