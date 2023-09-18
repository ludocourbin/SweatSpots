//
//  MapDetailsView.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import MapKit
import SwiftUI

struct MapDetailsView: View {
    @Binding var lookAroundScene: MKLookAroundScene?
    @Binding var showDetails: Bool
    @Binding var mapSelection: MKMapItem?
    @Binding var showConfirmationDialog: Bool

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
            DirectionsConfirmationDialogButtons(destinationCoordinate: mapSelection?.placemark.coordinate)
        }
    }
}
