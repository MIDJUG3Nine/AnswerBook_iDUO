import SwiftUI

/// One page of the open book, filling the watch face. While the crown is turning there is no
/// page yet (`page` is nil) and sheets of paper sweep past, one for each click of the crown.
/// With the wrist down (Always On) the answer stays, in pale ink on black.
struct WatchPageView: View {
    let page: Page?
    /// Pages flicked past so far; each new value sweeps one more sheet across the screen.
    let flicks: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isLuminanceReduced) private var isDimmed
    @State private var revealed = false

    var body: some View {
        GeometryReader { proxy in
            let scale = WatchMetrics.scale(for: proxy.size)

            ZStack {
                if isDimmed {
                    Color.black
                } else {
                    Paper(variant: page?.number ?? flicks)
                }

                if let page {
                    answer(page, scale: scale)
                } else if !reduceMotion && !isDimmed {
                    Paper(variant: flicks + 1)
                        .overlay(alignment: .leading) {
                            // The edge of the turning sheet throws a little shadow.
                            LinearGradient(colors: [.black.opacity(0.25), .clear], startPoint: .leading, endPoint: .trailing)
                                .frame(width: 10 * scale)
                        }
                        .id(flicks)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .clipped()
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .easeOut(duration: 1.1)) { revealed = true }
        }
    }

    private func answer(_ page: Page, scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Text(page.answer.text())
                .font(Theme.bookFont(size: (chinese ? 21 : 22) * scale, relativeTo: .title3, chinese: chinese))
                .lineSpacing((chinese ? 5 : 2) * scale)
                .tracking((chinese ? 1.5 : 0.3) * scale)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 16 * scale)
                // The answer seeps into the paper like ink.
                .blur(radius: revealed || reduceMotion ? 0 : 4)
                .opacity(revealed ? 1 : 0)
                .modifier(Ink(isDimmed: isDimmed))
            if !isDimmed {
                Ornament(scale: scale)
                    .padding(.top, 12 * scale)
                    .opacity(revealed ? 1 : 0)
            }
            Spacer()
            Text("Page \(page.number)")
                .font(Theme.bookFont(size: 11 * scale, relativeTo: .footnote))
                .modifier(Ink(isDimmed: isDimmed, color: Theme.fadedInk, dimmedOpacity: 0.4))
                .padding(.bottom, 14 * scale)
        }
        .padding(.top, 26 * scale)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var chinese: Bool { Answer.readsChinese() }
}

/// The aged paper, turned a different way for each page so the stains don't repeat.
private struct Paper: View {
    let variant: Int

    var body: some View {
        Color.clear
            .overlay {
                Image("PaperTall")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(x: variant.isMultiple(of: 2) ? -1 : 1, y: variant % 4 < 2 ? 1 : -1)
            }
            .clipped()
            .accessibilityHidden(true)
    }
}

/// Ink printed into the paper; on the dimmed screen there is no paper, so the words are pale instead.
private struct Ink: ViewModifier {
    let isDimmed: Bool
    var color: Color = Theme.ink
    var dimmedOpacity = 0.8

    func body(content: Content) -> some View {
        if isDimmed {
            content.foregroundStyle(Theme.parchment.opacity(dimmedOpacity))
        } else {
            content.printedInk(color)
        }
    }
}

/// A short rule with a diamond in the middle, like a printer's ornament.
private struct Ornament: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: 6 * scale) {
            Rectangle().frame(width: 22 * scale, height: 0.7)
            Rectangle().frame(width: 4 * scale, height: 4 * scale).rotationEffect(.degrees(45))
            Rectangle().frame(width: 22 * scale, height: 0.7)
        }
        .printedInk(Theme.fadedInk)
        .accessibilityHidden(true)
    }
}

#Preview("Page") {
    WatchPageView(page: Page(answer: Answer.all[1], number: 2), flicks: 0)
}

#Preview("Riffling") {
    WatchPageView(page: nil, flicks: 3)
}
