import HingeKit
import SwiftUI

@main
struct AnswerBookApp: App {
    init() {
        Theme.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            BookView()
                #if DEBUG
                .hingeSimulator(ProcessInfo.processInfo.environment["HINGE_SIMULATOR"] == "1", initialAngle: 0)
                #endif
        }
    }
}
