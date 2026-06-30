import MapKit
import SwiftData
import SwiftUI

struct MerchantDetailSheet: View {
    @Bindable var merchant: Merchant

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var mapItem: MKMapItem?
    @State private var isLoading = true
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: merchant.annotationSymbol)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(8)
                        .frame(width: 40, height: 40)
                        .background(merchant.annotationColor, in: RoundedRectangle(cornerRadius: 10))

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
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
            .confirmationDialog("Remove this merchant?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Remove", role: .destructive) {
                    modelContext.delete(merchant)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.visible)
        .task {
            let id = MKMapItem.Identifier(rawValue: merchant.mapItemIdentifier)
            guard let id = id else { return }
            let request = MKMapItemRequest(mapItemIdentifier: id)
            mapItem = try? await request.mapItem
            isLoading = false
        }
    }
}
