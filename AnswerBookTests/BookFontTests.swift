import CoreText
import Foundation
import Testing
@testable import AnswerBook

/// The Chinese font ships with only the characters the book prints. A new answer or string with
/// a character outside that set would quietly fall back to the system font, so these tests catch it.
@Suite struct BookFontTests {
    init() {
        Theme.registerFonts()
    }

    @Test(arguments: ["NotoSerifSC-Medium", "NotoSerifSC-Bold"])
    func chineseFontCoversEverythingTheBookPrints(fontName: String) throws {
        let zh = try #require(Bundle.main.path(forResource: "zh-Hans", ofType: "lproj").flatMap(Bundle.init(path:)))
        let interface = Self.interfaceKeys.map { zh.localizedString(forKey: $0, value: nil, table: nil) }
        let text = (Answer.all.map(\.zh) + interface).joined()
        // Format specifiers such as %lld are replaced by digits, which the font has.
        let missing = Self.missingCharacters(in: text.filter { !$0.isASCII }, fontName: fontName)
        #expect(missing.isEmpty, "Add these characters to the font subset (design/fonts/subset.py): \(missing)")
    }

    @Test(arguments: ["IM_FELL_English_Roman", "IM_FELL_English_SC"])
    func englishFontCoversEverythingTheBookPrints(fontName: String) {
        let text = (Answer.all.map(\.en) + Self.interfaceKeys).joined()
        let missing = Self.missingCharacters(in: text, fontName: fontName)
        #expect(missing.isEmpty, "Characters missing from \(fontName): \(missing)")
    }

    private static let interfaceKeys = [
        "Answer Book", "Open the book", "Tap to open", "Page %lld", "Turn the page", "Close the book",
        "Think of a question.",
    ]

    private static func missingCharacters(in text: String, fontName: String) -> String {
        let font = CTFontCreateWithName(fontName as CFString, 20, nil)
        // CoreText substitutes another font for an unknown name, so check we got the real one.
        guard CTFontCopyPostScriptName(font) as String == fontName else { return "font \(fontName) not found" }
        let missing = Set(text).filter { character in
            var units = Array(String(character).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: units.count)
            return !CTFontGetGlyphsForCharacters(font, &units, &glyphs, units.count)
        }
        return String(missing.sorted())
    }
}
