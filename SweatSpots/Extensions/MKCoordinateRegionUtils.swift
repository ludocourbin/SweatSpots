//
//  MKCoordinateRegionUtils.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import SwiftUI
import MapKit

extension MKCoordinateRegion {
    static let paris = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
}
