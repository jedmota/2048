import SwiftUI

@main
struct swiftui_testingApp: App {
    var body: some Scene {
        WindowGroup {
//            AnimatedBoardView()
            ContentView(viewModel: ViewModel())
        }
    }
}
