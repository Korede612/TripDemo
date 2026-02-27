import SwiftUI
import Combine

/// Centralizes navigation across push (NavigationStack) and modal presentations (sheet/fullScreenCover).
 final class NavigationCoordinator: ObservableObject {
    // Push-based navigation path
    @Published public var path = NavigationPath()

    // Modal presentations
    @Published public var activeSheet: AppRoute? = nil
    @Published public var activeFullScreen: AppRoute? = nil

    public init() {}

    // Helpers to drive navigation
    public func push(_ route: AppRoute) {
        path.append(route)
    }

    public func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    public func popToRoot() {
        path.removeLast(path.count)
    }

    public func presentSheet(_ route: AppRoute) {
        activeSheet = route
    }

    public func dismissSheet() {
        activeSheet = nil
    }

    public func presentFullScreen(_ route: AppRoute) {
        activeFullScreen = route
    }

    public func dismissFullScreen() {
        activeFullScreen = nil
    }
}
