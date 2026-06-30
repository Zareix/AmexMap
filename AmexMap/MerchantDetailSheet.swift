import MapKit
import SwiftUI

struct MerchantDetailSheet: View {
    let merchant: Merchant

    @State private var mapItem: MKMapItem?
    @State private var isLoading = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: merchant.annotationSymbol)
                .font(.title2)
                .foregroundStyle(.white)
                .padding(10)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .presentationDetents([.height(120)])
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
