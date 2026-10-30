import SwiftUI

/// Shown over the closed book each time the app opens: the book's name, then "Think of a question."
/// It lifts by itself after a few seconds. Tapping it means the reader is ready, so it opens the book.
struct QuestionPrompt: View {
    let onOpen: () -> Void
    let onDone: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
            // A little warm light, as if from a candle beside the book.
            RadialGradient(colors: [Color(hex: 0x3B2A12).opacity(0.6), .clear], center: .center, startRadius: 0, endRadius: 280)

            VStack(spacing: 26) {
                Text("Answer Book")
                    .font(Theme.bookFont(size: Theme.interfaceIsChinese ? 36 : 40, relativeTo: .largeTitle, bold: true, smallCaps: true))
                    .tracking(Theme.interfaceIsChinese ? 10 : 4)
                    .foregroundStyle(Theme.gold)
                    .shadow(color: Color(hex: 0xE9CF86).opacity(0.3), radius: 10)
                    .opacity(step >= 1 ? 1 : 0)
                Text("Think of a question.")
                    .font(Theme.bookFont(size: Theme.interfaceIsChinese ? 22 : 26, relativeTo: .title2))
                    .tracking(Theme.interfaceIsChinese ? 4 : 1)
                    .foregroundStyle(Theme.parchment)
                    .shadow(color: Color(hex: 0xE9CF86).opacity(0.25), radius: 8)
                    .blur(radius: step >= 2 || reduceMotion ? 0 : 5)
                    .opacity(step >= 2 ? 1 : 0)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Open the book", onOpen)
        .task {
            withAnimation(.easeOut(duration: reduceMotion ? 0.3 : 1.2)) { step = 1 }
            do {
                try await Task.sleep(for: .seconds(1.3))
                withAnimation(.easeOut(duration: reduceMotion ? 0.3 : 1.2)) { step = 2 }
                try await Task.sleep(for: .seconds(2.8))
            } catch {
                return // The book was opened or the app left the screen first.
            }
            onDone()
        }
    }
}

#Preview {
    QuestionPrompt(onOpen: {}, onDone: {})
        .background(Color.brown)
}
