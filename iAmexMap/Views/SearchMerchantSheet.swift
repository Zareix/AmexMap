import MapKit
import SwiftData
import SwiftUI

private struct PendingItem: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

private struct MerchantRow: View {
    let symbol: String
    let color: Color
    let name: String
    var subtitle: String? = nil
    var badge: (systemImage: String, color: Color)? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.callout)
                .foregroundStyle(.white)
                .padding(8)
                .frame(width: 40, height: 40)
                .background(color, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let badge {
                Image(systemName: badge.systemImage)
                    .foregroundStyle(badge.color)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SearchMerchantSheet: View {
    var onSelectSaved: ((Merchant) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Query private var savedMerchants: [Merchant]
    @State private var query = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    @State private var pendingItem: PendingItem?

    var filteredSaved: [Merchant] {
        guard !query.isEmpty else { return savedMerchants }
        return savedMerchants.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !filteredSaved.isEmpty {
                    Section("Saved") {
                        ForEach(filteredSaved) { merchant in
                            Button {
                                dismiss()
                                onSelectSaved?(merchant)
                            } label: {
                                MerchantRow(
                                    symbol: merchant.annotationSymbol,
                                    color: merchant.annotationColor,
                                    name: merchant.name.isEmpty ? "Unknown" : merchant.name,
                                    subtitle: merchant.address.isEmpty ? nil : merchant.address,
                                    badge: (
                                        systemImage: merchant.isAccepted ? "checkmark.circle.fill" : "xmark.circle.fill",
                                        color: merchant.isAccepted ? .green : .red
                                    )
                                )
                            }
                        }
                    }
                }

                if !results.isEmpty {
                    Section("Results") {
                        ForEach(results, id: \.self) { item in
                            Button {
                                pendingItem = PendingItem(item: item)
                            } label: {
                                let category = MKPointOfInterestCategory(rawValue: item.pointOfInterestCategory?.rawValue ?? "")
                                MerchantRow(
                                    symbol: category.sfSymbol,
                                    color: category.annotationColor,
                                    name: item.name ?? "Unknown",
                                    subtitle: item.address?.shortAddress ?? item.address?.fullAddress
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if isSearching {
                    ProgressView()
                } else if results.isEmpty && filteredSaved.isEmpty && !query.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, placement: .toolbar, prompt: "Search merchants")
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
            .sheet(item: $pendingItem) { pending in
                AddMerchantSheet(source: .item(pending.item))
            }
        }
        .padding(.top, 8)
        .presentationDetents([.height(70), .height(350), .large])
        .presentationBackgroundInteraction(.enabled)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled()
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

#Preview {
    @Previewable @State var showSheet = true
    Color.clear
        .ignoresSafeArea()
        .sheet(isPresented: $showSheet) {
            SearchMerchantSheet()
        }
        .modelContainer(for: Merchant.self, inMemory: true)
}
