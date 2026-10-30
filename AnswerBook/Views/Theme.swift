import CoreText
import SwiftUI

/// An old leather-bound book: black leather, gold foil, aged paper and brown ink.
/// The book looks the same in light and dark mode, like a real object would.
enum Theme {
    static let ink = Color(hex: 0x2B1D12)
    static let fadedInk = Color(hex: 0x6B5235)
    /// The colour of the page edges, also used for words written in candlelight.
    static let parchment = Color(hex: 0xE6D7B4)

    /// Gold foil: darker and lighter bands so it catches the light.
    static let gold = LinearGradient(
        colors: [0x7A5A24, 0xE9CF86, 0xA8823E, 0xF4E0A0, 0x806029].map(Color.init(hex:)),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The book's typeface: Noto Serif SC for Chinese, IM FELL English for everything else.
    /// IM FELL is a revival of 17th-century English type and keeps the uneven edges of letterpress.
    /// Neither font has the other's characters, so pass `chinese` for the text actually shown.
    static func bookFont(
        size: CGFloat,
        relativeTo style: Font.TextStyle,
        bold: Bool = false,
        smallCaps: Bool = false,
        chinese: Bool = interfaceIsChinese
    ) -> Font {
        let name = chinese
            ? (bold ? "NotoSerifSC-Bold" : "NotoSerifSC-Medium")
            : (smallCaps ? "IM_FELL_English_SC" : "IM_FELL_English_Roman")
        return .custom(name, size: size, relativeTo: style)
    }

    /// How much larger the type and ornaments are drawn in a space of this size (a page, or the cover).
    /// Phones and both iPhone Duo displays stay at 1, so the book looks the same there; an iPad
    /// page grows with its shorter side, up to 1.6 times, so the words don't sit lost in the middle.
    static func scale(for size: CGSize) -> CGFloat {
        min(max(min(size.width, size.height) / 500, 1), 1.6)
    }

    /// The interface strings are shown in Chinese (the app has English and Simplified Chinese).
    static let interfaceIsChinese = Bundle.main.preferredLocalizations.first?.hasPrefix("zh") == true

    /// The fonts ship with the app. Call once at launch, before any text is drawn.
    static func registerFonts() {
        let names = ["NotoSerifSC-Medium", "NotoSerifSC-Bold", "IMFellEnglish-Roman", "IMFellEnglishSC-Regular"]
        let urls = names.compactMap { Bundle.main.url(forResource: $0, withExtension: "ttf") }
        CTFontManagerRegisterFontURLs(urls as CFArray, .process, true, nil)
    }
}

extension View {
    /// Ink printed into paper rather than text floating above it: the paper shows through the ink,
    /// the edges bleed a little into the fibres, and the ink is thinner where the fibres didn't take it.
    func printedInk(_ color: Color = Theme.ink) -> some View {
        foregroundStyle(color)
            .shadow(color: color.opacity(0.45), radius: 0.5)
            .mask { Image("InkGrain").resizable(resizingMode: .tile) }
            .blendMode(.multiply)
    }

    /// Gold foil stamped into leather: rubbed away where the grain is deep, shadowed along the
    /// top edge of the impression and catching a little light along the bottom one.
    func foilStamped() -> some View {
        mask { Image("FoilWear").resizable(resizingMode: .tile) }
            .shadow(color: .black.opacity(0.9), radius: 0, y: -1)
            .shadow(color: Color(hex: 0xFFF0C8).opacity(0.1), radius: 0, y: 1)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
