import SwiftUI

@main
struct iMOVApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
