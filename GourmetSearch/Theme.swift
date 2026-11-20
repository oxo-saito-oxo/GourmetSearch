import SwiftUI

extension Color {
    /// こげ茶：文字・メインボタン
    static let appBrown = Color(red: 0x65 / 255, green: 0x43 / 255, blue: 0x21 / 255)
    /// はちみつ色：アクセント（スライダー・アイコン）
    static let appHoney = Color(red: 0xEA / 255, green: 0xA2 / 255, blue: 0x21 / 255)
    /// うすいはちみつ色：アイコンの背景・チップ
    static let appHoneyLight = Color(red: 0xFB / 255, green: 0xEB / 255, blue: 0xC8 / 255)
    /// クリーム：画面の背景
    static let appCream = Color(red: 0xFF / 255, green: 0xF8 / 255, blue: 0xEE / 255)
    /// 薄めの茶色：補足の文字
    static let appSubText = Color(red: 0x7A / 255, green: 0x5A / 255, blue: 0x3A / 255)
    /// 枠線
    static let appBorder = Color(red: 0xE3 / 255, green: 0xD2 / 255, blue: 0xBA / 255)
}

/// こげ茶のメインボタン
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appBrown, in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// 白地に枠線のサブボタン
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(Color.appBrown)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.appBrown, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
