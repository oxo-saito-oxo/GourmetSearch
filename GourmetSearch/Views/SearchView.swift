import SwiftUI

struct SearchView: View {
    @State private var rangeIndex: Double = 2
    @State private var selectedGenre = GenreOption.all[0]
    @State private var selectedFacilities: Set<Facility> = []
    @State private var path = NavigationPath()

    private var selectedRange: SearchRange {
        SearchRange.allCases[Int(rangeIndex)]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    locationCard
                    distanceCard
                    genreSection
                    facilitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color.appCream)
            .navigationDestination(for: SearchCondition.self) { condition in
                ShopListView(condition: condition)
            }
            .safeAreaInset(edge: .bottom) {
                searchButton
            }
        }
    }

    // MARK: - タイトル
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("[アプリ名]")
                .font(.footnote.bold())
                .foregroundStyle(Color.appSubText)
            Text("近くのお店を探す")
                .font(.title.bold())
                .foregroundStyle(Color.appBrown)
        }
    }

    // MARK: - 現在地カード
    private var locationCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundStyle(Color.appBrown)
                .frame(width: 44, height: 44)
                .background(Color.appHoneyLight, in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("現在地から探します")
                    .font(.headline)
                    .foregroundStyle(Color.appBrown)
                Text("検索ボタンを押したときの位置を使います")
                    .font(.footnote)
                    .foregroundStyle(Color.appSubText)
            }
            Spacer()
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.appBrown.opacity(0.08), radius: 10, y: 2)
    }

    // MARK: - 距離
    private var distanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("距離")
                    .font(.headline)
                Spacer()
                Text(selectedRange.label)
                    .font(.system(size: 40, weight: .bold))
                Text("以内")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.appSubText)
            }
            .foregroundStyle(Color.appBrown)

            Slider(value: $rangeIndex, in: 0...4, step: 1)
                .tint(Color.appHoney)
                .sensoryFeedback(.selection, trigger: rangeIndex)

            HStack {
                ForEach(SearchRange.allCases) { range in
                    Text(range.label)
                        .font(.footnote)
                        .fontWeight(range == selectedRange ? .bold : .regular)
                        .foregroundStyle(range == selectedRange ? Color.appBrown : Color.appSubText)
                    if range != SearchRange.allCases.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.appBrown.opacity(0.06), radius: 10, y: 2)
    }

    // MARK: - ジャンル
    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("ジャンル").font(.headline)
                Text("（任意）").font(.footnote).foregroundStyle(Color.appSubText)
            }
            .foregroundStyle(Color.appBrown)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(GenreOption.all) { genre in
                        ChipButton(title: genre.name, isSelected: genre == selectedGenre) {
                            selectedGenre = genre
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }

    // MARK: - こだわり条件
    private var facilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("こだわり条件").font(.headline)
                Text("（複数選べます）").font(.footnote).foregroundStyle(Color.appSubText)
            }
            .foregroundStyle(Color.appBrown)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Facility.allCases) { facility in
                        let isSelected = selectedFacilities.contains(facility)
                        ChipButton(
                            title: facility.label,
                            isSelected: isSelected,
                            systemImage: isSelected ? "checkmark" : "plus"
                        ) {
                            if isSelected {
                                selectedFacilities.remove(facility)
                            } else {
                                selectedFacilities.insert(facility)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    // MARK: - 検索ボタン
    private var searchButton: some View {
        Button {
            path.append(
                SearchCondition(
                    range: selectedRange,
                    genre: selectedGenre,
                    facilities: selectedFacilities
                )
            )
        } label: {
            Label("この周辺で探す", systemImage: "magnifyingglass")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appBrown, in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(Color.appCream)
    }
}

/// 丸いチップ型のボタン（ジャンル・こだわり条件で使う）
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.caption.bold())
                        .foregroundStyle(isSelected ? Color.appHoney : Color.appSubText)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .foregroundStyle(isSelected ? Color.white : Color.appBrown)
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(isSelected ? Color.appBrown : Color.white, in: Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SearchView()
}
