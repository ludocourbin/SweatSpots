//
//  WorkSpot.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//
import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit

struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let item: MKMapItem
}

struct WorkoutSpot: Identifiable, Decodable, Encodable {
    @DocumentID var id: String?
    var title: String
    var address: String
    var lat: Double
    var lon: Double
    var country: String

    enum CodingKeys: String, CodingKey {
        case title
        case address
        case lat
        case lon
        case country
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(address, forKey: .address)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
        try container.encode(country, forKey: .country)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        address = try container.decode(String.self, forKey: .address)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        country = try container.decode(String.self, forKey: .country)
    }
}

extension WorkoutSpot {
    var mapItem: MKMapItem {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = title
        return item
    }
}
