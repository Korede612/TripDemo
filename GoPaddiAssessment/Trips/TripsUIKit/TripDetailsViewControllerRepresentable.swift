//
//  TripDetailsViewControllerRepresentable.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import SwiftUI
import UIKit

struct TripDetailsViewControllerRepresentable: UIViewControllerRepresentable {
    let trip: Trip
    let coordinator: NavigationCoordinator
    
    func makeUIViewController(context: Context) -> TripDetailsViewController {
        return TripDetailsViewController(trip: trip, coordinator: coordinator)
    }
    
    func updateUIViewController(_ uiViewController: TripDetailsViewController, context: Context) {
        // No updates needed for now
    }
}
