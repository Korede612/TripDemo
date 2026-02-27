import Foundation

// MARK: - App Routes

enum AppRoute: Hashable {
    case selectCountry
    case countryList
    case countryDetail(code: String)
    case tripCreate
    case tripDetails(trip: Trip)
}

extension Trip: Hashable {
    public static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Modal Presentation Styles

enum ModalRoute: Hashable, Identifiable {
    case sheet(AppRoute)
    case fullScreen(AppRoute)

    public var id: String {
        switch self {
        case .sheet(let route):
            return "sheet_\(route.hashValue)"
        case .fullScreen(let route):
            return "full_\(route.hashValue)"
        }
    }
}
