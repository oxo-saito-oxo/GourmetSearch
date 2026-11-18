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
                List(viewModel.shops) { shop in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shop.name).bold()
                        Text(shop.access).font(.caption)
                    }
                }
            }
        }
        .navigationTitle("検索結果 \(viewModel.totalCount)件")
        .task {
            await viewModel.load()
        }
    }
}
