import SwiftUI

struct ShopListView: View {
    @State private var viewModel: ShopListViewModel

    init(condition: SearchCondition) {
        _viewModel = State(initialValue: ShopListViewModel(condition: condition))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("お店を探しています…")
            case .empty:
                Text("条件に合うお店が見つかりませんでした")
            case .error(let message):
                Text(message)
            case .loaded:
                shopList
            }
        }
        .foregroundStyle(Color.appBrown)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appCream)
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var shopList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                summary
                ForEach(viewModel.shops) { shop in
                    ShopCardView(shop: shop, distanceText: viewModel.distanceText(for: shop))
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
