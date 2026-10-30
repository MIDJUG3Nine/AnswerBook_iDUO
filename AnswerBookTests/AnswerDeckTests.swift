import Testing
@testable import AnswerBook

/// A small seeded generator so shuffles are repeatable in tests.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

@Suite struct AnswerDeckTests {
    @Test func noRepeatsWithinOneRound() {
        var deck = AnswerDeck()
        var generator = SeededGenerator(state: 1)
        let pages = (0..<deck.count).map { _ in deck.draw(using: &generator) }
        #expect(Set(pages.map(\.answer)).count == deck.count)
    }

    @Test(arguments: [1, 2, 3, 42, 2026] as [UInt64])
    func neverTheSameAnswerTwiceInARow(seed: UInt64) {
        var deck = AnswerDeck()
        var generator = SeededGenerator(state: seed)
        var previous: Answer?
        for _ in 0..<(deck.count * 5) {
            let answer = deck.draw(using: &generator).answer
            #expect(answer != previous)
            previous = answer
        }
    }

    @Test func singleAnswerBookStillWorks() {
        var deck = AnswerDeck(answers: [Answer(zh: "是", en: "Yes.")])
        #expect(deck.draw().answer.en == "Yes.")
        #expect(deck.draw().answer.en == "Yes.")
    }

    @Test func pageNumbersAreStable() {
        var deck = AnswerDeck()
        var generator = SeededGenerator(state: 7)
        for _ in 0..<(deck.count * 2) {
            let page = deck.draw(using: &generator)
            let index = Answer.all.firstIndex(of: page.answer)!
            #expect(page.number == AnswerDeck.pageNumber(for: index))
        }
    }

    @Test func answersAreUniqueAndNotEmpty() {
        let answers = Answer.all
        #expect(answers.count == 365)
        #expect(Set(answers.map(\.zh)).count == answers.count)
        #expect(Set(answers.map(\.en)).count == answers.count)
        #expect(answers.allSatisfy { !$0.zh.isEmpty && !$0.en.isEmpty })
    }

    @Test func languagePicksChineseForAnyChineseLocale() {
        let answer = Answer(zh: "是", en: "Yes.")
        #expect(answer.text(for: ["zh-Hans-MY"]) == "是")
        #expect(answer.text(for: ["zh-Hant"]) == "是")
        #expect(answer.text(for: ["ms-MY", "zh-Hans"]) == "Yes.")
        #expect(answer.text(for: []) == "Yes.")
    }
}
