import SwiftUI
import MapKit

struct AddMerchantSheet: View {
    let feature: MapFeature
    let onSave: (String, CLLocationCoordinate2D, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var merchantName: String?
    @State private var fetchedData: (identifier: String, coordinate: CLLocationCoordinate2D, category: String?)?

    var body: some View {
        VStack(spacing: 24) {
            if let data = fetchedData {
                Image(systemName: MKPointOfInterestCategory(rawValue: data.category ?? "").sfSymbol)
                    .font(.largeTitle)
                    .foregroundStyle(MKPointOfInterestCategory(rawValue: data.category ?? "").annotationColor)
            } else {
                Image(systemName: "mappin.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }

            if let name = merchantName {
                Text(name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } else {
                ProgressView()
                    .padding(.vertical, 4)
            }

            HStack(spacing: 12) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Add Merchant") {
                    if let data = fetchedData {
                        onSave(data.identifier, data.coordinate, data.category)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(fetchedData == nil)
            }
        }
        .padding(24)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
        .task {
            let request = MKMapItemRequest(feature: feature)
            guard let item = try? await request.mapItem,
                  let identifier = item.identifier?.rawValue else {
                merchantName = "No identifier available"
                return
            }
            merchantName = item.name ?? "Unknown Merchant"
            fetchedData = (identifier: identifier, coordinate: item.location.coordinate, category: item.pointOfInterestCategory?.rawValue)
        }
    }
}
