import SwiftUI

struct AppNavigationRoot: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @EnvironmentObject private var viewModel: TripPlannerViewModel

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TripPlannerRootView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                        .environmentObject(coordinator)
                        .environmentObject(viewModel)
                    
                }
                .sheet(item: Binding(
                    get: { coordinator.activeSheet.map { ModalRoute.sheet($0) } },
                    set: { newValue in
                        if case let .sheet(route)? = newValue { coordinator.activeSheet = route } else { coordinator.activeSheet = nil }
                    }
                )) { modal in
                    switch modal {
                    case .sheet(let route):
                        destinationView(for: route)
                            .presentationDetents(detentsForRoute(route))
                            .presentationDragIndicator(.visible)
                    default:
                        EmptyView()
                    }
                }
                .fullScreenCover(item: Binding(
                    get: { coordinator.activeFullScreen.map { ModalRoute.fullScreen($0) } },
                    set: { newValue in
                        if case let .fullScreen(route)? = newValue { coordinator.activeFullScreen = route } else { coordinator.activeFullScreen = nil }
                    }
                )) { modal in
                    switch modal {
                    case .fullScreen(let route):
                        destinationView(for: route)
                    default:
                        EmptyView()
                    }
                }
        }
        .environmentObject(coordinator)
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .selectCountry:
            SelectCountryView()
        case .countryList:
            CountryListView()
        case .countryDetail(let code):
            CountryDetailView(countryCode: code)
        case .tripCreate:
            TripCreatePresenter()
        case .tripDetails(let trip):
            TripDetailsViewControllerRepresentable(trip: trip, coordinator: coordinator)
        }
    }
    
    /// Returns appropriate presentation detents for each route
    /// This allows sheets to have dynamic heights based on their content
    private func detentsForRoute(_ route: AppRoute) -> Set<PresentationDetent> {
        switch route {
        case .selectCountry:
            // Small content, use medium detent with custom option
            // Medium is approximately 50% of screen height
            return [.medium]
            
        case .countryList:
            // Searchable list, allow medium and large with user selection
            // Users can drag between 50% and ~95% screen height
            return [.medium, .large]
            
        case .countryDetail:
            // Detail view, allow medium and large
            return [.medium, .large]
            
        case .tripCreate:
            // Form with multiple fields, use large with option to expand fully
            // Can also use custom detent for exact height: [.height(600), .large]
            return [.height(700)]
            
        case .tripDetails:
            // Trip details is full screen navigation, not modal
            return [.large]
        }
    }
}

#Preview("App Navigation") {
    // Provide a concrete TripPlannerViewModel here.
    fatalError("Provide a concrete TripPlannerViewModel instance for preview, e.g., AppNavigationRoot(viewModel: .mock)")
}
