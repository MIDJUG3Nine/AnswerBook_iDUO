import CoreGraphics

enum WatchMetrics {
    /// How much larger the type and ornaments are drawn on this screen. A 44 mm watch draws at 1,
    /// so a 40 mm watch is a little smaller and an Ultra a little larger.
    static func scale(for size: CGSize) -> CGFloat {
        min(max(min(size.width, size.height) / 184, 0.8), 1.2)
    }
}
