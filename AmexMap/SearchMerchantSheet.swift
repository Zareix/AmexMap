import MapKit
import SwiftUI

struct SearchMerchantSheet: View {
    let onSave: (String, CLLocationCoordinate2D, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            List(results, id: \.self) { item in
                Button {
                    guard let id = item.identifier?.rawValue else { return }
                    onSave(id, item.location.coordinate, item.pointOfInterestCategory?.rawValue)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name ?? "Unknown")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let address = item.address?.shortAddress ?? item.address?.fullAddress {
                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
            .overlay {
                if isSearching {
                    ProgressView()
                } else if results.isEmpty && !query.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search merchants")
            .onSubmit(of: .search) {
                Task { await search() }
            }
            .onChange(of: query) {
                guard !query.isEmpty else { results = []; return }
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    await search()
                }
            }
            .navigationTitle("Add Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func search() async {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        results = (try? await MKLocalSearch(request: request).start())?.mapItems ?? []
        isSearching = false
    }
}
