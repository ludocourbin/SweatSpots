//
//  MapDetailsView.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import MapKit
import SwiftUI

@available(iOS 17, *)
struct MapDetailsView: View {
    @Binding var lookAroundScene: MKLookAroundScene?
    @Binding var showDetails: Bool
    @Binding var mapSelection: MKMapItem?
    @Binding var routeDisplaying: Bool
    @Binding var route: MKRoute?
    @Binding var routeDestination: MKMapItem?

    @State private var showConfirmationDialog = false
    @State private var destinationCoordinate: CLLocationCoordinate2D?

    var body: some View {
        Group {
            VStack(spacing: 15) {
                ZStack {
                    if lookAroundScene == nil {
                        ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
                    } else {
                        LookAroundPreview(scene: $lookAroundScene)
                    }
                }
                .frame(height: 200)
                .clipShape(.rect(cornerRadius: 15))
                .overlay(alignment: .topTrailing) {
                    Button(action: {
                        showDetails = false
                        withAnimation(.snappy) {
                            mapSelection = nil
                        }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.black)
                            .background(.white, in: .circle)
                    })
                    .padding(10)
                }

                Button("Get Directions", action: {
                    destinationCoordinate = mapSelection?.placemark.coordinate
                    showConfirmationDialog = true
                })
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
            }
            .padding(15)
        }
        .presentationDetents([.height(300)])
        .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
        .presentationCornerRadius(25)
        .interactiveDismissDisabled(true)
        .confirmationDialog("Get Directions", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Apple Maps") {
                openAppleMapsDirections()
            }
            Button("Google Maps") {
                openGoogleMapsDirections()
            }
        }
    }

    func fetchRoute() {}

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
             UIApplication.shared.canOpenURL(googleMapsUrl) {
              UIApplication.shared.open(googleMapsUrl, options: [:])
          } else {
              if let appStoreUrl = URL(string: "https://apps.apple.com/app/google-maps/id585027354"),
                 UIApplication.shared.canOpenURL(appStoreUrl) {
                  UIApplication.shared.open(appStoreUrl, options: [:])
              }
          }
        
    }
}
