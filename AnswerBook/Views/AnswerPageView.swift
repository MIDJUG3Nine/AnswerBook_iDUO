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

            Group {
                switch spread {
                case .sideBySide:
                    HStack(spacing: 0) {
                        facingPage.frame(maxWidth: .infinity)
                        answerPage.frame(maxWidth: .infinity)
                    }
                case .stacked:
                    VStack(spacing: 0) {
                        facingPage.frame(maxHeight: .infinity)
                        answerPage.frame(maxHeight: .infinity)
                    }
                case .single:
                    answerPage
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background {
                paper(spread: spread).ignoresSafeArea()
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

    private var answerPage: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(page.answer.text())
                .font(.system(.largeTitle, design: .serif))
                .lineSpacing(6)
                .tracking(1)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 36)
                // The answer seeps into the paper like ink.
                .blur(radius: revealed || reduceMotion ? 0 : 6)
                .opacity(revealed ? 1 : 0)
            Ornament()
                .padding(.top, 28)
                .opacity(revealed ? 1 : 0)
            Spacer()
            Text("Page \(page.number)")
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(Theme.fadedInk.opacity(0.8))
                .padding(.bottom, 20)
        }
    }

    private var facingPage: some View {
        Image("Emblem")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 140, height: 140)
            .foregroundStyle(Theme.fadedInk.opacity(0.22))
            .accessibilityHidden(true)
    }

    private func paper(spread: Spread) -> some View {
        Color.clear
            .overlay {
                Image("Paper")
                    .resizable()
                    .scaledToFill()
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
}

/// A short rule with a diamond in the middle, like a printer's ornament.
private struct Ornament: View {
    var body: some View {
        HStack(spacing: 10) {
            Rectangle().frame(width: 36, height: 0.8)
            Rectangle().frame(width: 6, height: 6).rotationEffect(.degrees(45))
            Rectangle().frame(width: 36, height: 0.8)
        }
        .foregroundStyle(Theme.fadedInk.opacity(0.6))
        .accessibilityHidden(true)
    }
}

#Preview("Phone") {
    AnswerPageView(page: Page(answer: Answer.all[0], number: 7), isUnfolded: false, onTurn: {}, onClose: {})
}

#Preview("iPhone Duo, open", traits: .landscapeLeft) {
    AnswerPageView(page: Page(answer: Answer.all[1], number: 10), isUnfolded: true, onTurn: {}, onClose: {})
}
