import SwiftUI

struct CoverView: View {
    let hasHinge: Bool
    let onOpen: () -> Void

    var body: some View {
        ZStack {
            Theme.cover.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.accent)
                    .frame(width: 48, height: 3)
                    .accessibilityHidden(true)

                Text("Answer Book")
                    .font(.system(.largeTitle, design: .serif, weight: .semibold))
                    .foregroundStyle(Theme.coverText)

                Text(prompt)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Theme.coverText.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button(action: onOpen) {
                    Text("Open the book")
                        .font(.headline)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .foregroundStyle(Theme.cover)
                .padding(.bottom, 32)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }

    private var prompt: LocalizedStringKey {
        hasHinge
            ? "Think of your question, then open the book."
            : "Think of your question, then tap to open the book."
    }
}

#Preview {
    CoverView(hasHinge: false, onOpen: {})
}
