//
//  MapView.swift
//  MapKit17
//
//  Created by Ludovic Courbin on 14/07/2023.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: View {
    @ObservedObject var mapViewModel = MapViewModel()
    @StateObject var network = Network()
    private let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()

    // Map properties
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .region(.paris))
    @State private var mapSelection: MKMapItem?
    @Namespace private var locationSpace
    @State private var viewingRegion: MKCoordinateRegion?
    
    // Map Selection Detail Properties
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    
    // Route properties
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
                ForEach(mapViewModel.searchResults, id: \.self) { mapItem in
                    if routeDisplaying {
                        if mapItem == routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                    } else {
                        
                        let placemark = mapItem.placemark
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                            .tint(.blue)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .onMapCameraChange { ctx in
                viewingRegion = ctx.region
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
            .sheet(isPresented: $showDetails, onDismiss: {
                withAnimation(.snappy) {
                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(boundingRect.reducedRect(0.45))
                    }
                }
            }, content: {
                MapDetailsView(
                    lookAroundScene: $lookAroundScene,
                    showDetails: $showDetails,
                    mapSelection: $mapSelection,
                    routeDisplaying: $routeDisplaying,
                    route: $route,
                    routeDestination: $routeDestination
                )
            })
            .onChange(of: mapSelection) { _, newValue in
                guard network.connected else { return }
                showDetails = newValue != nil
                fetchLookAroundPreview()
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                mapViewModel.searchSpots(viewingRegion: viewingRegion)
            }
            
            VStack {
                Button(action: {
                    mapViewModel.searchSpots(viewingRegion: viewingRegion)
                }) {
                    Text("Search this area")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 10)
                }
                .padding(.top, 16)
                
                Spacer()
            }
        }
    }

    func fetchLookAroundPreview() {
        if let mapSelection = mapSelection {
            lookAroundScene = nil
            Task.detached(priority: .background) {
                do {
                    let latitude = mapSelection.placemark.coordinate.latitude
                    let longitude = mapSelection.placemark.coordinate.longitude
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude:longitude )

                    let request = MKLookAroundSceneRequest(coordinate: coordinate)
                    let scene = try await request.scene
                    DispatchQueue.main.async {
                        self.lookAroundScene = scene
                    }
                } catch {
                    print("Failed to fetch Look Around preview: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
