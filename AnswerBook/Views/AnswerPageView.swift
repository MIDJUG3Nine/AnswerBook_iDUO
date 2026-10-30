import SwiftUI

struct AnswerPageView: View {
    let page: Page
    let hasHinge: Bool
    let onTurn: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(page.answer.text())
                    .font(.system(.largeTitle, design: .serif, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 32)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Text("Page \(page.number)")
                    .font(.system(.footnote, design: .serif))
                    .foregroundStyle(Theme.ink.opacity(0.45))
                    .padding(.bottom, 16)

                if hasHinge {
                    Text("Flick the phone half shut to turn the page. Close it to start over.")
                        .font(.caption)
                        .foregroundStyle(Theme.ink.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 12)
                }

                HStack(spacing: 16) {
                    Button("Close the book", action: onClose)
                        .buttonStyle(.bordered)
                    Button("Turn the page", action: onTurn)
                        .buttonStyle(.borderedProminent)
                }
                .tint(Theme.ink)
                .padding(.bottom, 24)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40).onEnded { value in
                if value.translation.width < -40 { onTurn() }
            }
        )
    }
}

#Preview {
    AnswerPageView(page: Page(answer: Answer.all[0], number: 7), hasHinge: true, onTurn: {}, onClose: {})
}
