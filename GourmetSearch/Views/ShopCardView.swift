import SwiftUI

/// 一覧に並べるお店のカード
struct ShopCardView: View {
    let shop: Shop
    let distanceText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photo
            VStack(alignment: .leading, spacing: 6) {
                Text("\(shop.genre.name)・\(shop.budget.name)")
                    .font(.footnote)
                    .foregroundStyle(Color.appSubText)
                Text(shop.name)
                    .font(.headline)
                    .foregroundStyle(Color.appBrown)
                    .multilineTextAlignment(.leading)
                Label(shop.access, systemImage: "tram")
                    .font(.footnote)
                    .foregroundStyle(Color.appSubText)
                    .lineLimit(2)
            }
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.appBrown.opacity(0.08), radius: 12, y: 2)
    }

    /// 写真と、左上の距離バッジ
    private var photo: some View {
        Color.appHoneyLight
            .frame(height: 150)
            .overlay {
                AsyncImage(url: shop.largeImageURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.title)
                            .foregroundStyle(Color.appSubText)
                    }
                }
            }
            .clipped()
            .overlay(alignment: .topLeading) {
                if let distanceText {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color.appHoney)
                        Text(distanceText)
                            .foregroundStyle(Color.appBrown)
                    }
                    .font(.footnote.bold())
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(.white, in: Capsule())
                    .padding(12)
                }
            }
    }
}
