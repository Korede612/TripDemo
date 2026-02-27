//
//  TripCreatePresenter.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import SwiftUI

/// Wrapper view to present the Create Trip screen
struct TripCreatePresenter: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        CreateTripView()
            .navigationBarHidden(true)
    }
}

#Preview {
    TripCreatePresenter()
        .environmentObject(NavigationCoordinator())
}
