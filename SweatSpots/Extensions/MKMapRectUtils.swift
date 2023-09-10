//
//  MKMapRectUtils.swift
//  SweatSpots
//
//  Created by Ludovic Courbin on 09/09/2023.
//

import SwiftUI
import MapKit

extension MKMapRect {
    func reducedRect(_ fraction: CGFloat = 0.35) -> MKMapRect {
        var regionRect = self

        let wPadding = regionRect.size.width * fraction
        let hPadding = regionRect.size.height * fraction
                    
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
                    
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        
        return regionRect
    }
}
