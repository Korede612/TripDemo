//
//  TripPlannerRootView.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import SwiftUI

/// The top-level SwiftUI view. Hosts the entire UIKit trip planner screen
/// using `UIViewControllerRepresentable`, giving you full access to the
/// SwiftUI environment (modifiers, navigation, sheet presentation, etc.)
/// while keeping all UIKit code intact.
struct TripPlannerRootView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: TripPlannerViewModel
//    let viewModel: TripPlannerViewModel
    var body: some View {
        TripPlannerViewControllerRepresentable()
            .ignoresSafeArea() // Let the UIKit VC manage its own safe area insets
//            .environmentObject(coordinator)
    }
}

#Preview {
    TripPlannerRootView()
}
