//
//  ContentView.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TripPlannerViewModel()

    var body: some View {
        NavigationStack {
            AppNavigationRoot()
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .environmentObject(viewModel)
        }
        .task {
            await viewModel.loadTrips()
        }
    }
}

#Preview {
    ContentView()
}
