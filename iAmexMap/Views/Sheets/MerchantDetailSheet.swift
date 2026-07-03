import MapKit
import SwiftUI

struct MerchantDetailSheet: View {
    @Bindable var merchant: Merchant

    @Environment(\.dismiss) private var dismiss
    @Environment(MerchantStore.self) private var store
    @State private var mapItem: MKMapItem?
    @State private var isLoading = true
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    MerchantIcon(symbol: merchant.annotationSymbol, color: merchant.annotationColor)

                    if isLoading {
                        ProgressView()
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mapItem?.name ?? "Amex Merchant")
                                .font(.headline)
                            if let address = mapItem?.address?.shortAddress ?? mapItem?.address?.fullAddress {
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 14)

                Divider()

                Toggle(isOn: $merchant.isAccepted) {
                    Label(
                        merchant.isAccepted ? "Amex accepted" : "Amex not accepted",
                        systemImage: merchant.isAccepted ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundStyle(merchant.isAccepted ? .green : .red)
                }
                .onChange(of: merchant.isAccepted) { _, _ in
                    Task { await store.save(merchant) }
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                    .confirmationDialog("Remove this merchant?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                        Button("Remove", role: .destructive) {
                            Task {
                                await store.delete(merchant)
                                if store.lastErrorMessage == nil {
                                    dismiss()
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.visible)
        .presentationCompactAdaptation(.none)
        .alert("Something went wrong", isPresented: Binding(
            get: { store.lastErrorMessage != nil },
            set: { if !$0 { store.lastErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(store.lastErrorMessage ?? "")
        }
        .task {
            let id = MKMapItem.Identifier(rawValue: merchant.mapItemIdentifier)
            guard let id = id else { return }
            let request = MKMapItemRequest(mapItemIdentifier: id)
            mapItem = try? await request.mapItem
            isLoading = false
        }
    }
}

#Preview {
    let merchant = Merchant(identifier: "IA1EC51379DD1EE4F", name: "Starbucks", address: "3 Boulevard des Capucines, Paris", latitude: 48.8706383, longitude: 2.3310375, category: MKPointOfInterestCategory.cafe.rawValue, isAccepted: true)
    return Color.clear
        .sheet(isPresented: .constant(true)) {
            MerchantDetailSheet(merchant: merchant)
        }
        .environment(MerchantStore.preview())
}
