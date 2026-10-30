import CoreGraphics
import Testing
@testable import AnswerBook

@Suite struct LayoutScaleTests {
    /// Sizes in points of one page, or of the cover.
    @Test(arguments: [
        CGSize(width: 440, height: 956), // iPhone 17 Pro Max
        CGSize(width: 375, height: 667), // iPhone SE
        CGSize(width: 466, height: 678), // iPhone Duo, outer display
        CGSize(width: 475.5, height: 669), // iPhone Duo, inner display: one page of the spread
    ])
    func phonesKeepTheirSizes(size: CGSize) {
        #expect(Theme.scale(for: size) == 1)
    }

    @Test func iPadPagesGrowUpToALimit() {
        let mini = Theme.scale(for: CGSize(width: 744, height: 1133))
        let large = Theme.scale(for: CGSize(width: 1032, height: 1376))
        #expect(mini > 1.4 && mini < 1.6)
        #expect(large == 1.6)
    }
}
