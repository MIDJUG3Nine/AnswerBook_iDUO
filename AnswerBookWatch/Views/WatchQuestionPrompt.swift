import SwiftUI

/// Shown over the closed book each time the app opens: the book's name, then "Think of a question."
/// It lifts by itself after a few seconds. A tap or a turn of the crown opens the book straight away
/// (the book view handles both).
struct WatchQuestionPrompt: View {
    let onDone: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step = 0

    var body: some View {
        GeometryReader { proxy in
            let scale = WatchMetrics.scale(for: proxy.size)

            VStack(spacing: 12 * scale) {
                Text("Answer Book")
                    .font(Theme.bookFont(size: 22 * scale, relativeTo: .title2, bold: true, smallCaps: true))
                    .tracking((Theme.interfaceIsChinese ? 4 : 1.5) * scale)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Theme.gold)
                    .shadow(color: Color(hex: 0xE9CF86).opacity(0.3), radius: 6)
                    .opacity(step >= 1 ? 1 : 0)
                Text("Think of a question.")
                    .font(Theme.bookFont(size: 15 * scale, relativeTo: .body))
                    .tracking((Theme.interfaceIsChinese ? 2 : 0.5) * scale)
                    .foregroundStyle(Theme.parchment)
                    .shadow(color: Color(hex: 0xE9CF86).opacity(0.25), radius: 5)
                    .blur(radius: step >= 2 || reduceMotion ? 0 : 4)
                    .opacity(step >= 2 ? 1 : 0)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16 * scale)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background {
            ZStack {
                Color.black
                // A little warm light, as if from a candle beside the book.
                RadialGradient(colors: [Color(hex: 0x3B2A12).opacity(0.6), .clear], center: .center, startRadius: 0, endRadius: 140)
            }
        }
        .accessibilityElement(children: .combine)
        .task {
            withAnimation(.easeOut(duration: reduceMotion ? 0.3 : 1.0)) { step = 1 }
            do {
                try await Task.sleep(for: .seconds(1.1))
                withAnimation(.easeOut(duration: reduceMotion ? 0.3 : 1.0)) { step = 2 }
                try await Task.sleep(for: .seconds(2.4))
            } catch {
                return // The book was opened or the app left the screen first.
            }
            onDone()
        }
    }
}

#Preview {
    WatchQuestionPrompt(onDone: {})
}
