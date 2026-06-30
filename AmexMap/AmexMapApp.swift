import SwiftData
import SwiftUI

@main
struct AmexMapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Merchant.self])
        #if targetEnvironment(simulator)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        #else
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.raphaelgc.AmexMap")
        )
        #endif
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
