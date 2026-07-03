import SwiftUI

@main
struct iAmexMapApp: App {
    @State private var merchantStore = MerchantStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(merchantStore)
        }
    }
}
