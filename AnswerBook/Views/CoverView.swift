import SwiftUI

/// The closed book: black leather with a gold-foil frame, shown on the outer display.
struct CoverView: View {
    let hasHinge: Bool
    let onOpen: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let spine = min(proxy.size.width * 0.07, 30)
            let scale = Theme.scale(for: proxy.size)
            // The leather runs under the status bar and the home indicator, the gold frame stays clear of them.
            let insets = EdgeInsets(
                top: max(22, proxy.safeAreaInsets.top),
                leading: spine + 16,
                bottom: max(22, proxy.safeAreaInsets.bottom),
                trailing: 22
            )

            ZStack {
                Color.black

                // The page block, peeking out along the fore-edge and the bottom.
                PageEdges()
                    .clipShape(.rect(cornerRadius: 26))
                    .padding(EdgeInsets(top: 14, leading: spine, bottom: 3, trailing: 3))

                cover(spine: spine, frameInsets: insets, scale: scale)
                    .padding(EdgeInsets(top: 6, leading: 6, bottom: 11, trailing: 11))
            }
            // Fill the height, but keep clear of the camera strip beside the outer display.
            .ignoresSafeArea(edges: .vertical)
        }
        .background(Color.black.ignoresSafeArea())
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Answer Book")
        .accessibilityHint(hint)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Open the book", onOpen)
    }

    private func cover(spine: CGFloat, frameInsets: EdgeInsets, scale: CGFloat) -> some View {
        ZStack {
            Color.clear
                .overlay {
                    Image("Leather")
                        .resizable()
                        .scaledToFill()
                }

            // The groove where the cover bends at the spine.
            HStack(spacing: 0) {
                LinearGradient(colors: [.black.opacity(0.55), .black.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: spine)
                Rectangle().fill(.black.opacity(0.6)).frame(width: 2)
                Rectangle().fill(.white.opacity(0.06)).frame(width: 1)
                Spacer(minLength: 0)
            }

            frame(scale: scale)
                .padding(frameInsets)
        }
        .clipShape(.rect(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28).strokeBorder(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func frame(scale: CGFloat) -> some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 6).strokeBorder(Theme.gold, lineWidth: 2.5)
                RoundedRectangle(cornerRadius: 4).strokeBorder(Theme.gold, lineWidth: 1).padding(8)
                corners(size: 60 * scale)
            }
            .foilStamped()

            VStack(spacing: 28 * scale) {
                Spacer()
                Text("Answer Book")
                    .font(Theme.bookFont(size: (Theme.interfaceIsChinese ? 40 : 42) * scale, relativeTo: .largeTitle, bold: true, smallCaps: true))
                    .tracking((Theme.interfaceIsChinese ? 10 : 4) * scale)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Theme.gold)
                    .foilStamped()
                Image("Emblem")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128 * scale, height: 128 * scale)
                    .foilStamped()
                Spacer()
                Text(hint)
                    .font(Theme.bookFont(size: 15 * scale, relativeTo: .footnote))
                    .tracking(2 * scale)
                    .foregroundStyle(Theme.gold)
                    .opacity(0.65)
                    .foilStamped()
                    .padding(.bottom, 28 * scale)
            }
            .padding(.horizontal, 24)
        }
    }

    private func corners(size: CGFloat) -> some View {
        ZStack {
            Image("Corner").resizable().frame(width: size, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            Image("Corner").resizable().frame(width: size, height: size).scaleEffect(x: -1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            Image("Corner").resizable().frame(width: size, height: size).scaleEffect(y: -1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            Image("Corner").resizable().frame(width: size, height: size).scaleEffect(x: -1, y: -1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .padding(4)
        .accessibilityHidden(true)
    }

    private var hint: LocalizedStringKey {
        hasHinge ? "Open the book" : "Tap to open"
    }
}

/// Cream paper edges with fine lines, like a stack of pages seen from the side.
private struct PageEdges: View {
    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.parchment))
            let line = Color(hex: 0xB59F72)
            var y: CGFloat = 0
            while y < size.height {
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 0.6)), with: .color(line.opacity(0.7)))
                y += 2.5
            }
            var x: CGFloat = 0
            while x < size.width {
                context.fill(Path(CGRect(x: x, y: 0, width: 0.6, height: size.height)), with: .color(line.opacity(0.35)))
                x += 2.5
            }
        }
    }
}

#Preview("Cover") {
    CoverView(hasHinge: true, onOpen: {})
}
