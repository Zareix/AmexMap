import MapKit
import SwiftData
import SwiftUI

struct AddMerchantSheet: View {
    enum Source {
        case feature(MapFeature)
        case item(MKMapItem)
    }

    let source: Source

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var merchantName: String?
    @State private var isAccepted = true
    @State private var fetchedData: (identifier: String, address: String, coordinate: CLLocationCoordinate2D, category: String?)?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    if let data = fetchedData {
                        Image(systemName: MKPointOfInterestCategory(rawValue: data.category ?? "").sfSymbol)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                            .frame(width: 40, height: 40)
                            .background(MKPointOfInterestCategory(rawValue: data.category ?? "").annotationColor, in: RoundedRectangle(cornerRadius: 10))
                    } else {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    }

                    if let name = merchantName {
                        Text(name)
                            .font(.headline)
                    } else {
                        Text("Loading…")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 14)

                Divider()

                Picker("", selection: $isAccepted) {
                    Label("Accepted", systemImage: "checkmark.circle.fill").tag(true)
                    Label("Not accepted", systemImage: "xmark.circle.fill").tag(false)
                }
                .pickerStyle(.segmented)
                .disabled(fetchedData == nil)
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
            .navigationTitle("Add Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let data = fetchedData {
                            modelContext.insert(Merchant(
                                identifier: data.identifier,
                                name: merchantName ?? "",
                                address: data.address,
                                latitude: data.coordinate.latitude,
                                longitude: data.coordinate.longitude,
                                category: data.category,
                                isAccepted: isAccepted
                            ))
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(fetchedData == nil)
                }
            }
        }
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.visible)
        .task {
            let item: MKMapItem?
            switch source {
            case .feature(let feature):
                item = try? await MKMapItemRequest(feature: feature).mapItem
            case .item(let mapItem):
                item = mapItem
            }
            guard let item, let identifier = item.identifier?.rawValue else {
                merchantName = "No identifier available"
                return
            }
            merchantName = item.name ?? "Unknown Merchant"
            fetchedData = (
                identifier: identifier,
                address: item.address?.shortAddress ?? item.address?.fullAddress ?? "",
                coordinate: item.location.coordinate,
                category: item.pointOfInterestCategory?.rawValue
            )
        }
    }
}
