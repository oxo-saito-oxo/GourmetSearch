import SwiftUI

struct SearchView: View {
    @State private var selectedRange: SearchRange = .m1000

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("どのくらいの範囲で探す？")
                    .font(.headline)

                Picker("検索範囲", selection: $selectedRange) {
                    ForEach(SearchRange.allCases) { range in
                        Text(range.label).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                Button("この周辺で探す") {
                    print("選んだ範囲 \(selectedRange.label)")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("お店を探す")
        }
    }
}

#Preview {
    SearchView()
}
