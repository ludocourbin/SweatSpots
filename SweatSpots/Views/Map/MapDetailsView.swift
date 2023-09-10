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
                
//                Button("Get Directions", action: fetchRoute)
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .contentShape(Rectangle())
//                    .background(.blue.gradient, in: .rect(cornerRadius: 15))
            }
            .padding(15)
        }
        .presentationDetents([.height(300)])
        .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
        .presentationCornerRadius(25)
        .interactiveDismissDisabled(true)
    }
    
    func fetchRoute() {
        if let mapSelection = mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem.forCurrentLocation()
            request.destination = mapSelection
            request.transportType = .walking
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                    showDetails = false
                }
            }
        }
    }
}
