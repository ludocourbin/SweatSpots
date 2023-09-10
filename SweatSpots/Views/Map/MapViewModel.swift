//
//  MapViewModel.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import Foundation
import MapKit

class MapViewModel: ObservableObject {
    let geocoder = CLGeocoder()
    @Published var searchResults: [MKMapItem] = []
    let workoutSpotService = WorkoutSpotService()
    
    func searchSpots(viewingRegion: MKCoordinateRegion?) {
        guard let region = viewingRegion else { return }
         getUserCountry(from: region){ country in
             self.workoutSpotService.fetchNearBySpots(in: region, country: country) { spots in
                let mapItems = spots.map { $0.mapItem }
                self.searchResults = mapItems
            }
        }
        
    }
    
    private func getUserCountry(from region: MKCoordinateRegion, completion: @escaping (String) -> Void) {
        let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let country = placemarks?.first?.country {
                completion(country)
            } else {
                completion("France") // default to France if unable to determine country
            }
        }
    }
}
