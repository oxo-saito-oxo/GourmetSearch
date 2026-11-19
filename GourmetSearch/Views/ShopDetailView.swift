import SwiftUI

struct ShopDetailView: View {
    let shop: Shop
    let distanceText: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroPhoto
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    actionButtons
                    infoCard
                    facilitySection
                    credit
                }
                .padding(EdgeInsets(top: 32, leading: 20, bottom: 24, trailing: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.appCream,
                    in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                )
                .padding(.top, -24)
            }
        }
        .background(Color.appCream)
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 上の大きな写真
    private var heroPhoto: some View {
        Color.appHoneyLight
            .frame(height: 280)
            .overlay {
                AsyncImage(url: shop.largeImageURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundStyle(Color.appSubText)
                    }
                }
            }
            .clipped()
    }

    // MARK: - ボタン（経路・予約/電話・共有）
    private var actionButtons: some View {
        HStack(spacing: 10) {
            if let routeURL {
                Link(destination: routeURL) {
                    Label("経路を見る", systemImage: "location.north.line")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.appBrown, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            if let pageURL = shop.pageURL {
                Link(destination: pageURL) {
                    HStack(spacing: 6) {
                        Text("予約・電話")
                        Image(systemName: "arrow.up.right.square")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.appBrown)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBrown, lineWidth: 1.5))
                }

                ShareLink(item: pageURL, message: Text(shop.name)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(Color.appBrown)
                        .frame(width: 52, height: 52)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBorder, lineWidth: 1.5))
                }
                .accessibilityLabel("共有")
            }
        }
    }

    /// マップアプリで、現在地からお店までの徒歩の経路を開くURL
    private var routeURL: URL? {
        URL(string: "https://maps.apple.com/?daddr=\(shop.lat),\(shop.lng)&dirflg=w")
    }

    // MARK: - 設備・サービス
    private var facilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("設備・サービス")
                .font(.headline)
                .foregroundStyle(Color.appBrown)
            HStack(spacing: 0) {
                ForEach(Facility.allCases) { facility in
                    let available = facility.isAvailable(at: shop)
                    VStack(spacing: 6) {
                        Image(systemName: available ? "checkmark" : "minus")
                            .font(.caption.bold())
                            .foregroundStyle(available ? Color.appBrown : Color.appSubText)
                            .frame(width: 28, height: 28)
                            .background(available ? Color.appHoneyLight : Color.appCream, in: Circle())
                        Text(facility.shortLabel)
                            .font(.caption)
                            .fontWeight(available ? .bold : .regular)
                            .foregroundStyle(available ? Color.appBrown : Color.appSubText)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(facility.shortLabel) \(available ? "あり" : "なし")")
                }
            }
            .padding(.vertical, 12)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.appBrown.opacity(0.06), radius: 10, y: 2)
        }
    }

    // MARK: - APIのクレジット表示
    private var credit: some View {
        Text("Powered by ホットペッパーグルメ Webサービス")
            .font(.caption2)
            .foregroundStyle(Color.appSubText)
            .frame(maxWidth: .infinity)
    }

    // MARK: - 基本情報
    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "mappin.and.ellipse", label: "住所", value: shop.address)
            Divider()
            infoRow(icon: "tram", label: "アクセス", value: shop.access)
            Divider()
            infoRow(icon: "clock", label: "営業時間", value: shop.open)
            Divider()
            infoRow(icon: "calendar", label: "定休日", value: shop.close)
        }
        .padding(.horizontal, 16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.appBrown.opacity(0.06), radius: 10, y: 2)
    }

    /// 情報の1行（アイコン・項目名・内容）
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appBrown)
                .frame(width: 36, height: 36)
                .background(Color.appHoneyLight, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(Color.appSubText)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color.appBrown)
                    .textSelection(.enabled)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
    }

    // MARK: - 店名と、ジャンル・予算・距離
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(shop.name)
                .font(.title2.bold())
                .foregroundStyle(Color.appBrown)
            HStack(spacing: 10) {
                Text(shop.genre.name)
                dot
                Text(shop.budget.name)
                if let distanceText {
                    dot
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color.appHoney)
                        Text("現在地から\(distanceText)")
                            .bold()
                            .foregroundStyle(Color.appBrown)
                    }
                }
            }
            .font(.subheadline)
            .foregroundStyle(Color.appSubText)
        }
    }

    /// 区切りの小さな点
    private var dot: some View {
        Circle()
            .fill(Color.appHoney)
            .frame(width: 4, height: 4)
    }
}
