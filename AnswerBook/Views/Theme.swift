import SwiftUI
import UIKit

enum Theme {
    /// Cover: deep navy.
    static let cover = Color(hex: 0x0C2236)
    static let coverText = Color(hex: 0xF6F1E7)
    /// Bright blue, used for the bookmark line and the main button.
    static let accent = Color(hex: 0x38BDF8)

    /// Warm paper in light mode, a dark page at night.
    static let paper = Color(light: 0xF6F1E7, dark: 0x141C25)
    static let ink = Color(light: 0x0C2236, dark: 0xEDE6D8)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }
}
