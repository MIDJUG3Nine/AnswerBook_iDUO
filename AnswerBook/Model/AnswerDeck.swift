import Foundation

/// A page the reader landed on.
struct Page: Identifiable, Equatable, Sendable {
    let id = UUID()
    let answer: Answer
    let number: Int
}

/// Deals answers like shuffled cards: no repeats until every answer has been shown,
/// and never the same answer twice in a row.
struct AnswerDeck: Sendable {
    private let answers: [Answer]
    private var remaining: [Int] = []
    private var lastIndex: Int?

    init(answers: [Answer] = Answer.all) {
        precondition(!answers.isEmpty, "The book needs at least one answer.")
        self.answers = answers
    }

    var count: Int { answers.count }

    mutating func draw<G: RandomNumberGenerator>(using generator: inout G) -> Page {
        if remaining.isEmpty {
            remaining = Array(answers.indices).shuffled(using: &generator)
            // The next draw comes from the end; keep it different from the last page shown.
            if remaining.count > 1, remaining.last == lastIndex {
                remaining.swapAt(0, remaining.count - 1)
            }
        }
        let index = remaining.removeLast()
        lastIndex = index
        return Page(answer: answers[index], number: Self.pageNumber(for: index))
    }

    mutating func draw() -> Page {
        var generator = SystemRandomNumberGenerator()
        return draw(using: &generator)
    }

    /// Each answer always sits on the same page, like in a printed book: page 1 to page 365.
    static func pageNumber(for index: Int) -> Int {
        index + 1
    }
}
