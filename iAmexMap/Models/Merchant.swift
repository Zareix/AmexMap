import Foundation
import MapKit
import SwiftData
import SwiftUI

@Model
final class Merchant {
    var mapItemIdentifier: String = ""
    var name: String = ""
    var address: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var pointOfInterestCategory: String?
    var isAccepted: Bool = true

    // MARK: CloudKit System Fields (auto-populated)
    var modifiedBy: String?    // lastModifiedUserRecordID
    var createdAt: Date?       // creationDate
    var updatedAt: Date?       // modificationDate

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var annotationSymbol: String {
        guard let raw = pointOfInterestCategory else { return "mappin" }
        return MKPointOfInterestCategory(rawValue: raw).sfSymbol
    }

    var annotationColor: Color {
        guard let raw = pointOfInterestCategory else { return .red }
        return MKPointOfInterestCategory(rawValue: raw).annotationColor
    }

    init(identifier: String, name: String, address: String = "", latitude: Double, longitude: Double, category: String? = nil, isAccepted: Bool = true) {
        self.mapItemIdentifier = identifier
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.pointOfInterestCategory = category
        self.isAccepted = isAccepted
    }
}

extension MKPointOfInterestCategory {
    var sfSymbol: String {
        switch self {
        case .bakery: return "birthday.cake.fill"
        case .cafe: return "cup.and.saucer.fill"
        case .restaurant: return "fork.knife"
        case .foodMarket: return "cart.fill"
        case .store: return "bag.fill"
        case .pharmacy: return "pills.fill"
        case .hospital: return "cross.fill"
        case .gasStation: return "fuelpump.fill"
        case .parking: return "parkingsign"
        case .bank: return "building.columns.fill"
        case .atm: return "dollarsign.circle.fill"
        case .hotel: return "bed.double.fill"
        case .fitnessCenter: return "dumbbell.fill"
        case .spa: return "leaf.fill"
        case .beauty: return "scissors"
        case .theater: return "theatermasks.fill"
        case .movieTheater: return "film.fill"
        case .museum: return "building.columns.fill"
        case .library: return "books.vertical.fill"
        case .school: return "graduationcap.fill"
        case .university: return "graduationcap.fill"
        case .park: return "tree.fill"
        case .nationalPark: return "tree.fill"
        case .airport: return "airplane"
        case .publicTransport: return "tram.fill"
        case .brewery: return "wineglass.fill"
        case .winery: return "wineglass.fill"
        case .distillery: return "wineglass.fill"
        case .nightlife: return "music.note"
        case .stadium: return "sportscourt.fill"
        case .laundry: return "washer.fill"
        case .postOffice: return "envelope.fill"
        case .fireStation: return "flame.fill"
        case .police: return "shield.fill"
        case .marina: return "sailboat.fill"
        case .zoo: return "pawprint.fill"
        case .beach: return "sun.max.fill"
        case .musicVenue: return "music.note"
        case .landmark: return "star.fill"
        case .castle: return "building.columns.fill"
        default:
            if !rawValue.isEmpty {
                print("[Merchant] sfSymbol: unhandled category '\(rawValue)'")
            }
            return "mappin"
        }
    }

    var annotationColor: Color {
        switch self {
        case .bakery, .cafe, .restaurant, .foodMarket, .beauty:
            return .orange
        case .pharmacy, .hospital, .fireStation:
            return .red
        case .gasStation, .store:
            return .yellow
        case .parking:
            return .blue
        case .bank, .atm:
            return .green
        case .hotel:
            return .indigo
        case .fitnessCenter, .spa:
            return .teal
        case .theater, .movieTheater, .nightlife, .brewery, .winery, .distillery, .musicVenue:
            return .pink
        case .museum, .library, .castle:
            return .brown
        case .landmark:
            return .purple
        case .school, .university:
            return .blue
        case .park, .nationalPark, .beach:
            return .green
        case .airport, .publicTransport:
            return .blue
        case .police:
            return .blue
        case .marina:
            return .cyan
        case .zoo:
            return .green
        default:
            if !rawValue.isEmpty {
                print("[Merchant] annotationColor: unhandled category '\(rawValue)'")
            }
            return .gray
        }
    }
}
