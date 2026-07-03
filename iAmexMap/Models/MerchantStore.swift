import CloudKit
import MapKit
import Observation

@MainActor
@Observable
final class MerchantStore {
    var merchants: [Merchant] = []
    var lastErrorMessage: String?

    private let database: CKDatabase
    private let isPreview: Bool

    init(containerIdentifier: String = "iCloud.com.raphaelgc.iAmexMap", isPreview: Bool = false) {
        database = CKContainer(identifier: containerIdentifier).publicCloudDatabase
        self.isPreview = isPreview
    }

    func fetchAll() async {
        guard !isPreview else { return }
        do {
            var all: [CKRecord] = []
            var cursor: CKQueryOperation.Cursor?
            repeat {
                let page: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)
                if let cursor {
                    page = try await database.records(continuingMatchFrom: cursor)
                } else {
                    let query = CKQuery(recordType: Merchant.recordType, predicate: NSPredicate(value: true))
                    page = try await database.records(matching: query)
                }
                all.append(contentsOf: page.matchResults.compactMap { try? $0.1.get() })
                cursor = page.queryCursor
            } while cursor != nil
            merchants = all.compactMap(Merchant.init(record:))
        } catch {
            print("[MerchantStore] fetchAll error: \(error)")
            lastErrorMessage = "Couldn't load merchants."
        }
    }

    @discardableResult
    func save(_ merchant: Merchant) async -> Merchant {
        guard !isPreview else {
            if !merchants.contains(where: { $0.mapItemIdentifier == merchant.mapItemIdentifier }) {
                merchants.append(merchant)
            }
            return merchant
        }
        do {
            let recordID = CKRecord.ID(recordName: merchant.mapItemIdentifier)
            let record = (try? await database.record(for: recordID)) ?? CKRecord(recordType: Merchant.recordType, recordID: recordID)
            merchant.apply(to: record)
            let saved = try await database.save(record)
            merchant.update(from: saved)
            if !merchants.contains(where: { $0.mapItemIdentifier == merchant.mapItemIdentifier }) {
                merchants.append(merchant)
            }
        } catch {
            print("[MerchantStore] save error: \(error)")
            lastErrorMessage = "Couldn't save this merchant."
        }
        return merchant
    }

    func delete(_ merchant: Merchant) async {
        guard !isPreview else {
            merchants.removeAll { $0.mapItemIdentifier == merchant.mapItemIdentifier }
            return
        }
        do {
            let recordID = CKRecord.ID(recordName: merchant.mapItemIdentifier)
            _ = try await database.deleteRecord(withID: recordID)
            merchants.removeAll { $0.mapItemIdentifier == merchant.mapItemIdentifier }
        } catch {
            print("[MerchantStore] delete error: \(error)")
            lastErrorMessage = "Couldn't delete this merchant."
        }
    }
}

// MARK: - Preview support

extension MerchantStore {
    static func preview(seed: [Merchant]? = nil) -> MerchantStore {
        let store = MerchantStore(isPreview: true)
        store.merchants = seed ?? sampleMerchants
        return store
    }

    static let sampleMerchants: [Merchant] = [
        Merchant(
            identifier: "IA1EC51379DD1EE4F",
            name: "Starbucks",
            address: "3 Boulevard des Capucines, Paris",
            latitude: 48.8706383,
            longitude: 2.3310375,
            category: MKPointOfInterestCategory.cafe.rawValue,
            isAccepted: true
        )
    ]
}
