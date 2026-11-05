import SwiftUI

/// The whole watch app: the question, then the closed book, then a page.
///
/// Turn the Digital Crown to riffle through the book: each page that flicks past clicks under
/// your finger, and the page you stop on is your answer. Tapping opens the book and turns the
/// page too, and on watches with double tap, so does tapping finger and thumb together.
/// The book closes when the app leaves the screen, so coming back starts with the question.
struct WatchBookView: View {
    @State private var deck = AnswerDeck()
    @State private var stage = Stage.closed
    @State private var asksForQuestion = true
    /// Where the crown is, in pages. Only its changes matter: each one is a page flicking past.
    @State private var crown = 0.0
    /// Pages that have flicked past since the book was opened, so each one gets its own sweep.
    @State private var flicks = 0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// How long the crown has to rest before the book settles on a page.
    static let settleDelay = Duration.milliseconds(450)

    enum Stage: Equatable {
        case closed
        /// The crown is turning and the pages are flicking past, too fast to read.
        case riffling
        case open(Page)
    }

    var body: some View {
        Button(action: advance) {
            ZStack {
                switch stage {
                case .closed:
                    WatchCoverView()
                        .transition(coverTransition)
                        .zIndex(1)
                case .riffling:
                    WatchPageView(page: nil, flicks: flicks)
                        .transition(.opacity)
                case .open(let page):
                    WatchPageView(page: page, flicks: flicks)
                        .id(page.id)
                        .transition(.opacity)
                }

                if asksForQuestion && stage == .closed {
                    WatchQuestionPrompt {
                        withAnimation(.easeInOut(duration: 1.0)) { asksForQuestion = false }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
        }
        .buttonStyle(BookButtonStyle())
        .primaryHandGesture()
        .ignoresSafeArea()
        .focusable()
        .focusEffectDisabled()
        .digitalCrownRotation(
            detent: $crown,
            from: 0,
            through: Double(deck.count - 1),
            by: 1,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onChange(of: crown) { flick() }
        .task(id: flicks) {
            // The crown has come to rest once no page has flicked past for a moment.
            guard stage == .riffling else { return }
            do { try await Task.sleep(for: Self.settleDelay) } catch { return }
            land()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30).onEnded { value in
                if value.translation.height > 60 { closeBook() }
            }
        )
        .sensoryFeedback(.impact(weight: .medium), trigger: openPageID)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: stage == .closed ? "Open the book" as LocalizedStringKey : "Turn the page", advance)
        .accessibilityAction(named: "Close the book", closeBook)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                stage = .closed
                asksForQuestion = true
            }
        }
        #if DEBUG
        .onAppear(perform: skipAheadForScreenshots)
        #endif
    }

    #if DEBUG
    /// For screenshots: launch with ANSWERBOOK_STAGE=cover or page to start there instead of at the question.
    /// With `page`, ANSWERBOOK_PAGE=1…365 picks the page (for example the longest answers), otherwise it is random.
    private func skipAheadForScreenshots() {
        let environment = ProcessInfo.processInfo.environment
        switch environment["ANSWERBOOK_STAGE"] {
        case "cover":
            asksForQuestion = false
        case "page":
            asksForQuestion = false
            if let number = environment["ANSWERBOOK_PAGE"].flatMap(Int.init), Answer.all.indices.contains(number - 1) {
                stage = .open(Page(answer: Answer.all[number - 1], number: number))
            } else {
                stage = .open(deck.draw())
            }
        default:
            break
        }
    }
    #endif

    private var openPageID: UUID? {
        if case .open(let page) = stage { page.id } else { nil }
    }

    /// The cover swings open around the spine, unless Reduce Motion is on.
    private var coverTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .modifier(active: CoverSwing(angle: -100), identity: CoverSwing(angle: 0))
    }

    /// A tap or double tap: open the book, or turn to another page.
    private func advance() {
        switch stage {
        case .closed:
            withAnimation(.easeInOut(duration: 0.6)) {
                asksForQuestion = false
                stage = .open(deck.draw())
            }
        case .open:
            withAnimation(.easeInOut(duration: 0.35)) { stage = .open(deck.draw()) }
        case .riffling:
            break
        }
    }

    /// The crown moved one page.
    private func flick() {
        if stage != .riffling {
            withAnimation(.easeInOut(duration: stage == .closed ? 0.5 : 0.25)) {
                asksForQuestion = false
                stage = .riffling
            }
        }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) { flicks += 1 }
    }

    /// The crown stopped: the book falls open where it was.
    private func land() {
        guard stage == .riffling else { return }
        withAnimation(.easeInOut(duration: 0.3)) { stage = .open(deck.draw()) }
    }

    private func closeBook() {
        withAnimation(.easeInOut(duration: 0.5)) { stage = .closed }
    }
}

/// The whole screen is the button: no highlight when pressed, the book reacts by itself.
private struct BookButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.contentShape(Rectangle())
    }
}

private extension View {
    /// Double tap (Apple Watch Series 9, Ultra 2 and later) does what a tap does.
    @ViewBuilder func primaryHandGesture() -> some View {
        if #available(watchOS 11.0, *) {
            handGestureShortcut(.primaryAction)
        } else {
            self
        }
    }
}

private struct CoverSwing: ViewModifier {
    let angle: Double

    func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.4)
    }
}

#Preview {
    WatchBookView()
}
