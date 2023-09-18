//
//  DirectionsConfirmationDialog.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 16/09/2023.
//

import CoreLocation
import MapKit
import SwiftUI

struct DirectionsConfirmationDialogButtons: View {
    let locationManager = CLLocationManager()
    var destinationCoordinate: CLLocationCoordinate2D?  

    var body: some View {
        Group {
            Button("Apple Maps") {
                openAppleMapsDirections()
            }
            Button("Google Maps") {
                openGoogleMapsDirections()
            }
            
        }
    }

    func openAppleMapsDirections() {
        guard let destinationCoordinate = destinationCoordinate else { return }
        let placemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    func openGoogleMapsDirections() {
        guard let destinationCoordinate = destinationCoordinate else { return }
        let googleMapsUrlString = "comgooglemaps://?saddr=&daddr=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&directionsmode=walking"

        if let googleMapsUrl = URL(string: googleMapsUrlString),
           UIApplication.shared.canOpenURL(googleMapsUrl)
        {
            UIApplication.shared.open(googleMapsUrl, options: [:])
        } else {
            if let appStoreUrl = URL(string: "https://apps.apple.com/app/google-maps/id585027354"),
               UIApplication.shared.canOpenURL(appStoreUrl)
            {
                UIApplication.shared.open(appStoreUrl, options: [:])
            }
        }
    }

    // FIX: This does not work, https://github.com/mapsme/omim/issues/6386
    func openMapsMeDirections() {
        guard let destinationCoordinate = destinationCoordinate else { return }

        let sourceLat = locationManager.location?.coordinate.latitude
        let sourceLon = locationManager.location?.coordinate.longitude

        guard let sourceLat = sourceLat, let sourceLon = sourceLon else { return }
        let destinationName = "SUPERSPOT"
        let sourceName = "YOU"

        let mapsMeUrlString = "mapsme://route?sll=\(sourceLat),\(sourceLon)&saddr=\(sourceName)&dll=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&daddr=\(destinationName)&type=pedestrian"

        if let mapsMeUrl = URL(string: mapsMeUrlString),
           UIApplication.shared.canOpenURL(mapsMeUrl)
        {
            UIApplication.shared.open(mapsMeUrl, options: [:])
        } else {
            if let appStoreUrl = URL(string: "https://apps.apple.com/app/maps-me-offline-maps/id510623322"),
               UIApplication.shared.canOpenURL(appStoreUrl)
            {
                UIApplication.shared.open(appStoreUrl, options: [:])
            }
        }
    }
}
