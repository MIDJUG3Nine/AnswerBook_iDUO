import SwiftUI

/// An old leather-bound book: black leather, gold foil, aged paper and brown ink.
/// The book looks the same in light and dark mode, like a real object would.
enum Theme {
    static let ink = Color(hex: 0x2B1D12)
    static let fadedInk = Color(hex: 0x6B5235)

    /// Gold foil: darker and lighter bands so it catches the light.
    static let gold = LinearGradient(
        colors: [0x7A5A24, 0xE9CF86, 0xA8823E, 0xF4E0A0, 0x806029].map(Color.init(hex:)),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
