import SwiftUI

struct ShopListView: View {
    @State private var viewModel: ShopListViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(condition: SearchCondition) {
        _viewModel = State(initialValue: ShopListViewModel(condition: condition))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("お店を探しています…")
            case .loaded:
                shopList
            case .empty:
                emptyView
            case .error(let message):
                errorView(message: message)
            case .locationDenied:
                locationDeniedView
            }
        }
        .foregroundStyle(Color.appBrown)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appCream)
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Shop.self) { shop in
            ShopDetailView(shop: shop, distanceText: viewModel.distanceText(for: shop))
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - 0件のとき
    private var emptyView: some View {
        ContentUnavailableView {
            Label("条件に合うお店が見つかりませんでした", systemImage: "fork.knife")
        } description: {
            Text(viewModel.condition.range.next == nil
                 ? "ジャンルやこだわり条件を変えると、見つかるかもしれません。"
                 : "距離を広げるか、こだわり条件を減らすと見つかるかもしれません。")
        } actions: {
            VStack(spacing: 10) {
                if let next = viewModel.condition.range.next {
                    Button("\(next.label)以内に広げて探す") {
                        Task { await viewModel.widenRange() }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                Button("条件を変える") {
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .frame(width: 280)
        }
    }

    // MARK: - 位置情報が拒否されているとき
    private var locationDeniedView: some View {
        ContentUnavailableView {
            Label("位置情報がオフになっています", systemImage: "location.slash")
        } description: {
            Text("近くのお店を探すには、設定アプリで位置情報の利用を許可してください。")
        } actions: {
            Button("設定を開く") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 280)
        }
    }

    // MARK: - 通信エラーなど
    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("うまく読み込めませんでした", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("もう一度試す") {
                Task { await viewModel.load() }
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(width: 280)
        }
    }

    private var shopList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                summary
                ForEach(viewModel.shops) { shop in
                    NavigationLink(value: shop) {
                        ShopCardView(shop: shop, distanceText: viewModel.distanceText(for: shop))
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.hasNextPage {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("次のページを読み込み中…")
                            .font(.footnote)
                            .foregroundStyle(Color.appSubText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .task(id: viewModel.shops.count) {
                        await viewModel.loadMore()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    /// 「1km以内」「1,097件」の表示
    private var summary: some View {
        HStack(spacing: 8) {
            Label("\(viewModel.condition.range.label)以内", systemImage: "mappin.and.ellipse")
                .font(.footnote.bold())
                .padding(.horizontal, 12)
                .frame(height: 28)
                .background(Color.appHoneyLight, in: Capsule())
            Text("\(viewModel.totalCount.formatted())件")
                .font(.subheadline)
                .foregroundStyle(Color.appSubText)
        }
    }
}
