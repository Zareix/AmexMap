import MapKit
import SwiftUI

struct SelectedFeature: Identifiable {
    let id = UUID()
    let feature: MapFeature
}

struct ContentView: View {
    @Environment(MerchantStore.self) private var store

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedFeature: MapFeature?
    @State private var pendingFeature: SelectedFeature?
    @State private var selectedMerchant: Merchant?
    @State private var locationManager = CLLocationManager()

    @State private var showSearch = true
    @State private var searchSheetDetent: PresentationDetent = .height(70)
    @State private var searchSheetHeight: CGFloat = 0

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedFeature) {
            UserAnnotation()
            ForEach(store.merchants) { merchant in
                Annotation("", coordinate: merchant.coordinate) {
                    Button {
                        selectedMerchant = merchant
                    } label: {
                        MerchantIcon(symbol: merchant.annotationSymbol, color: merchant.annotationColor, size: 28)
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: merchant.isAccepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white, merchant.isAccepted ? .green : .red)
                                    .offset(x: 4, y: -4)
                            }
                    }
                }
                .annotationTitles(.hidden)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .task {
            await store.fetchAll()
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                cameraPosition = .userLocation(fallback: .automatic)
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)
                    .padding(12)
            }
            .glassEffect()
            .padding(.trailing, 16)
            .offset(y: -searchSheetHeight)
        }
        .onChange(of: selectedMerchant) {
            guard let merchant = selectedMerchant else { return }
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: merchant.coordinate,
                    latitudinalMeters: 500,
                    longitudinalMeters: 500
                ))
            }
        }
        .onChange(of: selectedFeature) {
            guard let feature = selectedFeature else { return }
            selectedFeature = nil
            pendingFeature = SelectedFeature(feature: feature)
        }
        .sheet(isPresented: $showSearch) {
            SearchMerchantSheet(onSelectSaved: { merchant in
                selectedMerchant = merchant
            })
            .onGeometryChange(for: CGFloat.self) {
                max(min($0.size.height, 350), 0)
            } action: { _, newValue in
                searchSheetHeight = min(newValue, 300)
            }
            .sheet(item: $pendingFeature) { selected in
                AddMerchantSheet(source: .feature(selected.feature))
            }
            .sheet(item: $selectedMerchant) { merchant in
                MerchantDetailSheet(merchant: merchant)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(MerchantStore.preview())
}
