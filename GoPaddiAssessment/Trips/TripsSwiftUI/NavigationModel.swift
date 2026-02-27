import SwiftUI
import Combine

// A simple navigation model to be used with NavigationStack path-based navigation.
// Stores a stack of routes as Strings (e.g., country codes) to match current usage.
//final class NavigationModel: ObservableObject {
//    // Using String as the path element type since CountryDetailView uses a country code (String).
//    @Published var path: [String] = []
//
//    // Convenience to clear the entire path (pop to root)
//    func popToRoot() {
//        path.removeAll()
//    }
//}
