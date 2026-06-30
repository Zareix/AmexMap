import MapKit
import SwiftData
import SwiftUI

private struct PendingItem: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

struct SearchMerchantSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    @State private var pendingItem: PendingItem?

    var body: some View {
        NavigationStack {
            List(results, id: \.self) { item in
                Button {
                    pendingItem = PendingItem(item: item)
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
            .sheet(item: $pendingItem) { pending in
                ConfirmSearchMerchantSheet(item: pending.item, onAdded: { dismiss() })
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

private struct ConfirmSearchMerchantSheet: View {
    let item: MKMapItem
    let onAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isAccepted = true

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: MKPointOfInterestCategory(rawValue: item.pointOfInterestCategory?.rawValue ?? "").sfSymbol)
                .font(.largeTitle)
                .foregroundStyle(MKPointOfInterestCategory(rawValue: item.pointOfInterestCategory?.rawValue ?? "").annotationColor)

            Text(item.name ?? "Unknown Merchant")
                .font(.headline)
                .multilineTextAlignment(.center)

            Picker("", selection: $isAccepted) {
                Label("Accepted", systemImage: "checkmark.circle.fill").tag(true)
                Label("Not accepted", systemImage: "xmark.circle.fill").tag(false)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Add Merchant") {
                    guard let id = item.identifier?.rawValue else { return }
                    modelContext.insert(Merchant(
                        identifier: id,
                        latitude: item.location.coordinate.latitude,
                        longitude: item.location.coordinate.longitude,
                        category: item.pointOfInterestCategory?.rawValue,
                        isAccepted: isAccepted
                    ))
                    dismiss()
                    onAdded()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(24)
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }
}
