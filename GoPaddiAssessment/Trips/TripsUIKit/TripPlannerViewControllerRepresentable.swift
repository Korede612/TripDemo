//
//  TripPlannerViewControllerRepresentable.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import SwiftUI

/// Wraps the UIKit `TripPlannerViewController` for use inside a SwiftUI view hierarchy.
/// The ViewModel, networking, and all UIKit views remain completely unchanged.
struct TripPlannerViewControllerRepresentable: UIViewControllerRepresentable {

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: TripPlannerViewModel
//    let viewModel: TripPlannerViewModel
    
    func makeUIViewController(context: Context) -> TripPlannerViewController {
        TripPlannerViewController(viewModel: viewModel, coordinator: coordinator)
    }

    func updateUIViewController(_ uiViewController: TripPlannerViewController, context: Context) {
        // No SwiftUI-driven updates needed — the VC manages its own state via Combine
    }
}
