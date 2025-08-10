import SwiftUI

@main
struct CurbAppealAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppViewModel())
        }
    }
}