import SwiftUI

/// The open book: an aged page with nothing on it but the answer.
///
/// On the iPhone Duo's inner display it is a two-page spread with the answer on one page,
/// so nothing sits on the crease: side by side when the display is wider than tall, one above
/// the other when it is held upright. On the outer display and on regular phones it is one page.
/// Tap to turn the page, swipe down to close the book.
struct AnswerPageView: View {
    let page: Page
    /// The device is open, so the inner display (and its crease) is in use.
    let isUnfolded: Bool
    let onTurn: () -> Void
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    var body: some View {
        GeometryReader { proxy in
            let spread = Spread(size: proxy.size, isUnfolded: isUnfolded)
            let scale = Theme.scale(for: spread.pageSize(in: proxy.size))

            Group {
                switch spread {
                case .sideBySide:
                    HStack(spacing: 0) {
                        facingPage(scale: scale).frame(maxWidth: .infinity)
                        answerPage(scale: scale).frame(maxWidth: .infinity)
                    }
                case .stacked:
                    VStack(spacing: 0) {
                        facingPage(scale: scale).frame(maxHeight: .infinity)
                        answerPage(scale: scale).frame(maxHeight: .infinity)
                    }
                case .single:
                    answerPage(scale: scale)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background {
                paper(spread: spread, isWide: proxy.size.width > proxy.size.height).ignoresSafeArea()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTurn)
        .gesture(
            DragGesture(minimumDistance: 40).onEnded { value in
                if value.translation.height > 80 { onClose() }
            }
        )
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 1.1)) { revealed = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityAction(named: "Turn the page", onTurn)
        .accessibilityAction(named: "Close the book", onClose)
    }

    private func answerPage(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Text(page.answer.text())
                .font(Theme.bookFont(size: (chinese ? 34 : 38) * scale, relativeTo: .largeTitle, chinese: chinese))
                .lineSpacing((chinese ? 10 : 4) * scale)
                .tracking((chinese ? 2 : 0.5) * scale)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 36 * scale)
                // The answer seeps into the paper like ink.
                .blur(radius: revealed || reduceMotion ? 0 : 6)
                .opacity(revealed ? 1 : 0)
                .printedInk()
            Ornament(scale: scale)
                .padding(.top, 28 * scale)
                .opacity(revealed ? 1 : 0)
            Spacer()
            Text("Page \(page.number)")
                .font(Theme.bookFont(size: 15 * scale, relativeTo: .footnote))
                .printedInk(Theme.fadedInk)
                .padding(.bottom, 20 * scale)
        }
    }

    private func facingPage(scale: CGFloat) -> some View {
        Image("Emblem")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 140 * scale, height: 140 * scale)
            .printedInk(Theme.fadedInk.opacity(0.3))
            .accessibilityHidden(true)
    }

    private var chinese: Bool { Answer.readsChinese() }

    private func paper(spread: Spread, isWide: Bool) -> some View {
        Color.clear
            .overlay {
                Image(isWide ? "PaperWide" : "PaperTall")
                    .resizable()
                    .scaledToFill()
                    // Each page turns the sheet a different way, so the stains don't repeat page after page.
                    .scaleEffect(x: page.number.isMultiple(of: 2) ? -1 : 1, y: page.number % 4 < 2 ? 1 : -1)
            }
            .clipped()
            .overlay {
                if spread != .single {
                    // Shadow in the gutter, where the pages curve into the spine.
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.40),
                            .init(color: .black.opacity(0.10), location: 0.48),
                            .init(color: .black.opacity(0.22), location: 0.50),
                            .init(color: .black.opacity(0.10), location: 0.52),
                            .init(color: .clear, location: 0.60),
                        ],
                        startPoint: spread == .sideBySide ? .leading : .top,
                        endPoint: spread == .sideBySide ? .trailing : .bottom
                    )
                }
            }
    }
}

private enum Spread {
    case single, sideBySide, stacked

    init(size: CGSize, isUnfolded: Bool) {
        if size.width > size.height * 1.1 {
            self = .sideBySide
        } else if isUnfolded && size.height > size.width * 1.1 {
            self = .stacked
        } else {
            self = .single
        }
    }

    /// The size of one page of the spread.
    func pageSize(in size: CGSize) -> CGSize {
        switch self {
        case .single: size
        case .sideBySide: CGSize(width: size.width / 2, height: size.height)
        case .stacked: CGSize(width: size.width, height: size.height / 2)
        }
    }
}

/// A short rule with a diamond in the middle, like a printer's ornament.
private struct Ornament: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 10 * scale) {
            Rectangle().frame(width: 36 * scale, height: 0.8 * scale)
            Rectangle().frame(width: 6 * scale, height: 6 * scale).rotationEffect(.degrees(45))
            Rectangle().frame(width: 36 * scale, height: 0.8 * scale)
        }
        .printedInk(Theme.fadedInk)
        .accessibilityHidden(true)
    }
}

#Preview("Phone") {
    AnswerPageView(page: Page(answer: Answer.all[0], number: 7), isUnfolded: false, onTurn: {}, onClose: {})
}

#Preview("iPhone Duo, open", traits: .landscapeLeft) {
    AnswerPageView(page: Page(answer: Answer.all[1], number: 10), isUnfolded: true, onTurn: {}, onClose: {})
}
