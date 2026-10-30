import HingeKit
import SwiftUI

/// The whole app: a cover while the book is closed, a random page once it opens.
///
/// On iPhone Duo the hinge drives it: open the phone to open the book, flick it
/// half shut to turn the page, close it to go back to the cover. On other devices
/// the buttons do the same.
struct BookView: View {
    @State private var deck = AnswerDeck()
    @State private var page: Page?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        FoldReader { fold in
            ZStack {
                if let page {
                    AnswerPageView(
                        page: page,
                        hasHinge: fold.posture != .noHinge,
                        onTurn: turnPage,
                        onClose: closeBook
                    )
                    .id(page.id)
                    .transition(pageTransition)
                } else {
                    CoverView(hasHinge: fold.posture != .noHinge, onOpen: openBook)
                        .transition(.opacity)
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
    }

    private var pageTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity)
    }

    private func openBook() {
        withAnimation(.easeOut(duration: 0.35)) { page = deck.draw() }
    }

    private func turnPage() {
        withAnimation(.easeInOut(duration: 0.3)) { page = deck.draw() }
    }

    private func closeBook() {
        withAnimation(.easeIn(duration: 0.25)) { page = nil }
    }
}

#Preview("Book with simulated hinge") {
    BookView()
        .hingeSimulator(initialAngle: 0)
}

#Preview("Book on a phone without a hinge") {
    BookView()
}
