import CoreText
import Foundation
import Testing
import UIKit
@testable import AnswerBookWatch

/// The watch app borrows the iPhone app's answers, fonts, textures and strings.
/// These check that all of them actually made it into the watch app.
@Suite struct WatchBookTests {
    init() {
        Theme.registerFonts()
    }

    @Test(arguments: ["NotoSerifSC-Medium", "NotoSerifSC-Bold", "IM_FELL_English_Roman", "IM_FELL_English_SC"])
    func bookFontsLoadOnTheWatch(fontName: String) {
        let font = CTFontCreateWithName(fontName as CFString, 20, nil)
        // CoreText substitutes another font for an unknown name, so check we got the real one.
        #expect(CTFontCopyPostScriptName(font) as String == fontName)
    }

    @Test(arguments: ["Leather", "PaperTall", "InkGrain", "FoilWear", "Emblem"])
    func texturesAreInTheWatchApp(name: String) {
        #expect(UIImage(named: name) != nil)
    }

    @Test func coverHintIsTranslated() throws {
        let zh = try #require(Bundle.main.path(forResource: "zh-Hans", ofType: "lproj").flatMap(Bundle.init(path:)))
        #expect(zh.localizedString(forKey: "Turn the crown", value: nil, table: nil) == "转动表冠")
        #expect(zh.localizedString(forKey: "Think of a question.", value: nil, table: nil) == "想一个问题吧")
    }

    @Test func theWholeBookIsOnTheWatch() {
        #expect(AnswerDeck().count == 365)
    }

    /// Screen sizes in points, from the smallest watch to the largest.
    @Test func typeScalesWithTheScreen() {
        let small = WatchMetrics.scale(for: CGSize(width: 162, height: 197)) // 40 mm
        let medium = WatchMetrics.scale(for: CGSize(width: 184, height: 224)) // 44 mm
        let large = WatchMetrics.scale(for: CGSize(width: 205, height: 251)) // Ultra 49 mm
        #expect(small < medium && medium < large)
        #expect(medium == 1)
        #expect(small >= 0.8 && large <= 1.2)
    }
}
