import SwiftUI

@main
struct AnswerBookWatchApp: App {
    init() {
        Theme.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            WatchBookView()
        }
    }
}
