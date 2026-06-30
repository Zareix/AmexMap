import MapKit
import SwiftData
import SwiftUI

struct SelectedFeature: Identifiable {
    let id = UUID()
    let feature: MapFeature
}

struct ContentView: View {
    @Query private var merchants: [Merchant]

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedFeature: MapFeature?
    @State private var pendingFeature: SelectedFeature?
    @State private var selectedMerchant: Merchant?
    @State private var locationManager = CLLocationManager()
    @State private var showSearch = false

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedFeature) {
            UserAnnotation()
            ForEach(merchants) { merchant in
                Annotation("", coordinate: merchant.coordinate) {
                    Button {
                        selectedMerchant = merchant
                    } label: {
                        Image(systemName: merchant.annotationSymbol)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(merchant.annotationColor, in: Circle())
                            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
                            .frame(width: 32, height: 32)
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
        .overlay(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 54)
                }

                Button {
                    cameraPosition = .userLocation(fallback: .automatic)
                } label: {
                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                        .frame(width: 50, height: 54)
                }
            }
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .padding(.bottom, 40)
            .padding(.trailing, 16)
        }
        .sheet(isPresented: $showSearch) {
            SearchMerchantSheet(onSelectSaved: { merchant in
                selectedMerchant = merchant
            })
        }
        .onChange(of: selectedFeature) {
            guard let feature = selectedFeature else { return }
            selectedFeature = nil
            pendingFeature = SelectedFeature(feature: feature)
        }
        .sheet(item: $pendingFeature) { selected in
            AddMerchantSheet(source: .feature(selected.feature))
        }
        .sheet(item: $selectedMerchant) { merchant in
            MerchantDetailSheet(merchant: merchant)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Merchant.self, inMemory: true)
}
