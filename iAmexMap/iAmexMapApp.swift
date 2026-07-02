import SwiftData
import SwiftUI

@main
struct iAmexMapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Merchant.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .public("iCloud.com.raphaelgc.iAmexMap")
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
