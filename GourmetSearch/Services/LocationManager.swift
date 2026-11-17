import CoreLocation
import Observation

/// 位置情報まわりのエラー
enum LocationError: LocalizedError {
    /// 位置情報の利用が許可されていない
    case denied
    /// 現在地の取得に失敗した
    case failed

    var errorDescription: String? {
        switch self {
        case .denied:
            return "位置情報の利用が許可されていません。設定アプリから許可してください。"
        case .failed:
            return "現在地を取得できませんでした。"
        }
    }
}

/// 現在地を取得するクラス
/// 使う側は `try await locationManager.requestLocation()` と書くだけで、
/// 許可ダイアログ → 現在地の取得 までを待てる
@MainActor
@Observable
final class LocationManager: NSObject {
    /// 位置情報の許可の状態（画面で「許可されていません」と出すときに使う）
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    @ObservationIgnored private let manager = CLLocationManager()
    /// 「結果が来たら再開する」ための待ち合わせ場所
    @ObservationIgnored private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        // お店探しなら100m程度の精度で十分（高精度にすると時間と電池を使う）
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    /// 許可されていない状態かどうか
    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    /// 現在地を1回だけ取得する
    /// まだ許可を聞いていなければ、先に許可ダイアログを出す
    func requestLocation() async throws -> CLLocation {
        // 前の取得がまだ終わっていなければ、それは失敗として終わらせる
        finish(.failure(LocationError.failed))

        if isDenied {
            throw LocationError.denied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            if manager.authorizationStatus == .notDetermined {
                // 結果は locationManagerDidChangeAuthorization に届く
                manager.requestWhenInUseAuthorization()
            } else {
                // 結果は didUpdateLocations か didFailWithError に届く
                manager.requestLocation()
            }
        }
    }

    /// 待っている処理に結果を渡して、待ち合わせを終える
    private func finish(_ result: Result<CLLocation, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}

// MARK: - CLLocationManagerDelegate（CoreLocation からの知らせを受け取る）

extension LocationManager: CLLocationManagerDelegate {
    /// 許可の状態が変わったとき（ダイアログで選ばれたときなど）
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            authorizationStatus = self.manager.authorizationStatus

            // 現在地を待っている処理がなければ、状態を更新するだけ
            guard continuation != nil else { return }

            switch self.manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            case .denied, .restricted:
                finish(.failure(LocationError.denied))
            default:
                break   // まだ選ばれていない
            }
        }
    }

    /// 現在地が取れたとき
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        MainActor.assumeIsolated {
            finish(.success(location))
        }
    }

    /// 現在地が取れなかったとき
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            finish(.failure(LocationError.failed))
        }
    }
}
