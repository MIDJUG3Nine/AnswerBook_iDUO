import HingeKit
import SwiftUI

@main
struct AnswerBookApp: App {
    var body: some Scene {
        WindowGroup {
            BookView()
                #if DEBUG
                .hingeSimulator(ProcessInfo.processInfo.environment["HINGE_SIMULATOR"] == "1", initialAngle: 0)
                #endif
        }
    }
}
