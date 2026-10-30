import HingeKit
import SwiftUI

/// The whole app: a cover while the book is closed, a random page once it opens.
/// Each time the app comes to the screen the book starts closed, and the reader is asked
/// to think of their question before opening it.
///
/// On iPhone Duo the hinge drives it: open the phone to open the book, flick it
/// half shut to turn the page, close it to go back to the cover. On other devices
/// tapping does the same: tap the cover to open, tap a page to turn it, swipe down to close.
struct BookView: View {
    @State private var deck = AnswerDeck()
    @State private var page: Page?
    @State private var asksForQuestion = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        FoldReader { fold in
            ZStack {
                if let page {
                    AnswerPageView(page: page, isUnfolded: fold.posture.isOpen, onTurn: turnPage, onClose: closeBook)
                        .id(page.id)
                        .transition(.opacity)
                } else {
                    CoverView(hasHinge: fold.posture != .noHinge, onOpen: openBook)
                        .transition(coverTransition)
                        .zIndex(1)
                }

                if asksForQuestion && page == nil {
                    QuestionPrompt(onOpen: openBook) {
                        withAnimation(.easeInOut(duration: 1.0)) { asksForQuestion = false }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
        }
        .onFoldEvent { event in
            switch event {
            case .opened: openBook()
            case .pageTurn: turnPage()
            case .closed: closeBook()
            case .postureChanged: break
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: page?.id)
        .onChange(of: scenePhase) { _, phase in
            // Close the book when the app leaves the screen, so coming back starts with the question.
            if phase == .background {
                page = nil
                asksForQuestion = true
            }
        }
    }

    /// The cover swings open around the spine, unless Reduce Motion is on.
    private var coverTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .modifier(active: CoverSwing(angle: -100), identity: CoverSwing(angle: 0))
    }

    private func openBook() {
        withAnimation(.easeInOut(duration: 0.6)) {
            asksForQuestion = false
            page = deck.draw()
        }
    }

    private func turnPage() {
        withAnimation(.easeInOut(duration: 0.35)) { page = deck.draw() }
    }

    private func closeBook() {
        withAnimation(.easeInOut(duration: 0.5)) { page = nil }
    }
}

private struct CoverSwing: ViewModifier {
    let angle: Double

    func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.4)
    }
}

#Preview("Book with simulated hinge") {
    BookView()
        .hingeSimulator(initialAngle: 0)
}

#Preview("Book on a phone without a hinge") {
    BookView()
}
