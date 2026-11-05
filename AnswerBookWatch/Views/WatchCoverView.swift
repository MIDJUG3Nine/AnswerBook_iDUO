import SwiftUI

/// The closed book on the wrist: black leather with a gold-foil frame that follows the screen's corners.
/// With the wrist down (Always On) only the gold title stays, on black.
struct WatchCoverView: View {
    @Environment(\.isLuminanceReduced) private var isDimmed

    var body: some View {
        GeometryReader { proxy in
            let scale = WatchMetrics.scale(for: proxy.size)

            ZStack {
                if isDimmed {
                    Color.black
                } else {
                    leather(spine: 12 * scale)
                    frame(scale: scale)
                }

                VStack(spacing: 10 * scale) {
                    Spacer()
                    Text("Answer Book")
                        .font(Theme.bookFont(size: 22 * scale, relativeTo: .title2, bold: true, smallCaps: true))
                        .tracking((Theme.interfaceIsChinese ? 4 : 1.5) * scale)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundStyle(Theme.gold)
                        .foilStamped()
                        .opacity(isDimmed ? 0.6 : 1)
                    if !isDimmed {
                        Image("Emblem")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50 * scale, height: 50 * scale)
                            .foilStamped()
                    }
                    Spacer()
                    Text("Turn the crown")
                        .font(Theme.bookFont(size: 12 * scale, relativeTo: .footnote))
                        .tracking(1 * scale)
                        .foregroundStyle(Theme.gold)
                        .opacity(isDimmed ? 0 : 0.65)
                        .foilStamped()
                        .padding(.bottom, 20 * scale)
                }
                .padding(.leading, 12 * scale)
                .padding(.horizontal, 24 * scale)
            }
        }
        .background(Color.black)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Answer Book")
        .accessibilityHint("Turn the crown")
        .accessibilityAddTraits(.isButton)
    }

    private func leather(spine: CGFloat) -> some View {
        ZStack {
            Color.clear
                .overlay {
                    Image("Leather")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()

            // The groove where the cover bends at the spine, on the left like the phone's.
            HStack(spacing: 0) {
                LinearGradient(colors: [.black.opacity(0.55), .black.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: spine)
                Rectangle().fill(.black.opacity(0.6)).frame(width: 1.5)
                Rectangle().fill(.white.opacity(0.06)).frame(width: 1)
                Spacer(minLength: 0)
            }
        }
    }

    private func frame(scale: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30 * scale).strokeBorder(Theme.gold, lineWidth: 2)
            RoundedRectangle(cornerRadius: 25 * scale).strokeBorder(Theme.gold, lineWidth: 0.8).padding(5 * scale)
        }
        .foilStamped()
        .padding(EdgeInsets(top: 8 * scale, leading: 22 * scale, bottom: 8 * scale, trailing: 8 * scale))
        .accessibilityHidden(true)
    }
}

#Preview {
    WatchCoverView()
}
