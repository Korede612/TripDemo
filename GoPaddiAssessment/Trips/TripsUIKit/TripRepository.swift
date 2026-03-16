//
//  TripRepository.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

// MARK: - Network/TripRepository.swift

import Foundation

// MARK: - API Requests

struct FetchTripsRequest: APIRequest {
    typealias Response = [Trip]
    let path = "/trips"
    let status: TripStatus?

    var queryItems: [URLQueryItem]? {
        guard let status else { return nil }
        return [URLQueryItem(name: "status", value: status.rawValue)]
    }
}

struct FetchCitiesRequest: APIRequest {
    typealias Response = [City]
    let path = "/cities"
}

struct CreateTripRequest: APIRequest {
    typealias Response = Trip
    let path = "/trips"
    let method: HTTPMethod = .POST

    struct Body: Codable {
        let destination: String
        let startDate: Date
        let endDate: Date
        let tripName: String
    }
    let body: Encodable?

    init(destination: String, startDate: Date, endDate: Date, tripName: String = "New Trip") {
        body = Body(destination: destination, startDate: startDate, endDate: endDate, tripName: tripName)
    }
}

// MARK: - Repository Protocol

protocol TripRepositoryProtocol {
    func fetchTrips(status: TripStatus?) async throws -> [Trip]
    func fetchCities() async throws -> [City]
    func createTrip(destination: String, startDate: Date, endDate: Date, tripName: String) async throws -> Trip
}

// MARK: - Live Repository

final class TripRepository: TripRepositoryProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol = HTTPClient.shared) {
        self.client = client
    }

    func fetchTrips(status: TripStatus?) async throws -> [Trip] {
        try await client.send(FetchTripsRequest(status: status))
    }

    func fetchCities() async throws -> [City] {
        try await client.send(FetchCitiesRequest())
    }

    func createTrip(destination: String, startDate: Date, endDate: Date, tripName: String = "New Trip") async throws -> Trip {
        try await client.send(CreateTripRequest(destination: destination, startDate: startDate, endDate: endDate, tripName: tripName))
    }
}

//// MARK: - Mock Repository
//
//final class MockTripRepository: TripRepositoryProtocol {
//    static let shared = MockTripRepository()
//
//    private let mockTrips: [Trip] = {
//        let calendar = Calendar.current
//        let base = Date()
//
//        return [
//            Trip(
//                id: UUID(),
//                title: "Bahamas Family Trip",
//                destination: "Paris",
//                startDate: DateComponents(calendar: calendar, year: 2024, month: 4, day: 19).date!,
//                endDate: DateComponents(calendar: calendar, year: 2024, month: 4, day: 24).date!,
//                imageURL: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600",
//                status: .planned
//            ),
//            Trip(
//                id: UUID(),
//                title: "Tokyo Adventure",
//                destination: "Tokyo",
//                startDate: DateComponents(calendar: calendar, year: 2024, month: 6, day: 10).date!,
//                endDate: DateComponents(calendar: calendar, year: 2024, month: 6, day: 17).date!,
//                imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600",
//                status: .planned
//            ),
//            Trip(
//                id: UUID(),
//                title: "Rome Escape",
//                destination: "Rome",
//                startDate: DateComponents(calendar: calendar, year: 2024, month: 7, day: 5).date!,
//                endDate: DateComponents(calendar: calendar, year: 2024, month: 7, day: 10).date!,
//                imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=600",
//                status: .planned
//            ),
//            Trip(
//                id: UUID(),
//                title: "New York City Break",
//                destination: "New York",
//                startDate: DateComponents(calendar: calendar, year: 2024, month: 3, day: 1).date!,
//                endDate: DateComponents(calendar: calendar, year: 2024, month: 3, day: 5).date!,
//                imageURL: "https://images.unsplash.com/photo-1490644658840-3f2e3f8c5625?w=600",
//                status: .completed
//            ),
//            Trip(
//                id: UUID(),
//                title: "Bali Retreat",
//                destination: "Bali",
//                startDate: calendar.date(byAdding: .day, value: -2, to: base)!,
//                endDate: calendar.date(byAdding: .day, value: 5, to: base)!,
//                imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600",
//                status: .ongoing
//            )
//        ]
//    }()
//
//    func fetchTrips(status: TripStatus?) async throws -> [Trip] {
//        try await Task.sleep(nanoseconds: 800_000_000)
//        if let status {
//            return mockTrips.filter { $0.status == status }
//        }
//        return mockTrips
//    }
//
//    func fetchCities() async throws -> [City] {
//        try await Task.sleep(nanoseconds: 400_000_000)
//        return [
////            City(id: UUID(), name: "Paris", country: "France", imageURL: ""),
////            City(id: UUID(), name: "Tokyo", country: "Japan", imageURL: ""),
////            City(id: UUID(), name: "New York", country: "USA", imageURL: ""),
////            City(id: UUID(), name: "Rome", country: "Italy", imageURL: ""),
////            City(id: UUID(), name: "Bali", country: "Indonesia", imageURL: ""),
//        ]
//    }
//
//    func createTrip(destination: String, startDate: Date, endDate: Date, tripName: String = "") async throws -> Trip {
//        try await Task.sleep(nanoseconds: 600_000_000)
//        return Trip(
//            id: UUID(),
//            title: "\(destination) Trip",
//            destination: destination,
//            startDate: startDate,
//            endDate: endDate,
//            imageURL: "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600",
//            status: .planned
//        )
//    }
//}
