//
//  WorkoutSpotService.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import MapKit

class WorkoutSpotService {
    private var db: Firestore
    private var spotsCollection: CollectionReference
    private let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()

    @Published var searchResults: [MKMapItem] = []

    init() {
        db = Firestore.firestore()
        spotsCollection = db.collection("spots")
    }

    func fetchNearBySpots(in region: MKCoordinateRegion, country: String, completion: @escaping ([WorkoutSpot]) -> Void) {
        fetchDataFor(country: country) { workoutSpots in
    
            let filteredSpots = workoutSpots.filter { spot in
                let latitude = spot.lat
                let longitude = spot.lon
                    
                let bounds = self.computeBounds(for: region)
                    
                return latitude >= bounds.southBound && latitude <= bounds.northBound && longitude >= bounds.westBound && longitude <= bounds.eastBound
            }
            completion(filteredSpots)
        }
    }
    
    func fetchDataFor(country: String, completion: @escaping ([WorkoutSpot]) -> Void) {
        print("Trying to fetch data for country: \(country)")
        if let storedData = UserDefaults.standard.data(forKey: country) {
            print("Stored data for \(country): \(storedData)")
            
            do {
                let decodedData = try JSONDecoder().decode([WorkoutSpot].self, from: storedData)
                completion(decodedData)
                return
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }
            
        print("I DIDN'T GET THE DATA for \(country)")
            
        let query = spotsCollection.whereField("country", isEqualTo: country)
        query.getDocuments { snapshot, error in
            
            if let error = error {
                print("Error fetching spots for \(country): \(error.localizedDescription)")
            }
            
            if let documents = snapshot?.documents {
                print("Fetched \(documents.count) spots for \(country)")
                let spots: [WorkoutSpot] = documents.compactMap { try? $0.data(as: WorkoutSpot.self) }
                do {
                    let encodedData = try JSONEncoder().encode(spots)
                    print("Encoded data: \(encodedData) for \(country)")
                    UserDefaults.standard.set(encodedData, forKey: country)
                    completion(spots)
                } catch {
                    print("Encoding error: \(error.localizedDescription)")
                }

            } else {
                completion([])
            }
        }
    }
    
    private func getUserCountry(completion: @escaping (String) -> Void) {
        if let location = locationManager.location {
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let country = placemarks?.first?.country {
                    completion(country)
                } else {
                    completion("France")
                }
            }
        }
    }
    
    private func computeBounds(for region: MKCoordinateRegion) -> (northBound: Double, southBound: Double, eastBound: Double, westBound: Double) {
        let northBound = region.center.latitude + region.span.latitudeDelta / 2
        let southBound = region.center.latitude - region.span.latitudeDelta / 2
        let eastBound = region.center.longitude + region.span.longitudeDelta / 2
        let westBound = region.center.longitude - region.span.longitudeDelta / 2
        return (northBound, southBound, eastBound, westBound)
    }
}
