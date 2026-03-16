//
//  ModelsTests.swift
//  GoPaddiAssessmentTests
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import XCTest
@testable import GoPaddiAssessment

final class ModelsTests: XCTestCase {
    
    // MARK: - Trip Model Tests
    
    func testTrip_DurationDaysCalculation() {
        // Given
        let calendar = Calendar.current
        let startDate = Date()
        let endDate = calendar.date(byAdding: .day, value: 5, to: startDate)!
        
        let trip = Trip(
            id: UUID(),
            title: "Test Trip",
            destination: "Paris",
            startDate: startDate,
            endDate: endDate,
            imageURL: "https://example.com/image.jpg",
            status: .planned
        )
        
        // When
        let duration = trip.durationDays
        
        // Then
        XCTAssertEqual(duration, 5, "Duration should be 5 days")
    }
    
    func testTrip_DurationDaysForSameDay() {
        // Given
        let startDate = Date()
        let endDate = startDate
        
        let trip = Trip(
            id: UUID(),
            title: "Test Trip",
            destination: "Paris",
            startDate: startDate,
            endDate: endDate,
            imageURL: "https://example.com/image.jpg",
            status: .planned
        )
        
        // When
        let duration = trip.durationDays
        
        // Then
        XCTAssertEqual(duration, 0, "Duration should be 0 for same day trip")
    }
    
    func testTrip_FormattedStartDate() {
        // Given
        let dateComponents = DateComponents(year: 2026, month: 3, day: 15)
        let calendar = Calendar.current
        let startDate = calendar.date(from: dateComponents)!
        
        let trip = Trip(
            id: UUID(),
            title: "Test Trip",
            destination: "Paris",
            startDate: startDate,
            endDate: startDate,
            imageURL: "https://example.com/image.jpg",
            status: .planned
        )
        
        // When
        let formatted = trip.formattedStartDate
        
        // Then
        XCTAssertTrue(formatted.contains("15"), "Should contain day")
        XCTAssertTrue(formatted.contains("March"), "Should contain month")
        XCTAssertTrue(formatted.contains("2026"), "Should contain year")
    }
    
    func testTrip_Codable() throws {
        // Given
        let originalTrip = Trip(
            id: UUID(),
            title: "Test Trip",
            destination: "Paris",
            startDate: Date(),
            endDate: Date(),
            imageURL: "https://example.com/image.jpg",
            status: .planned
        )
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTrip)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedTrip = try decoder.decode(Trip.self, from: data)
        
        XCTAssertEqual(decodedTrip.id, originalTrip.id)
        XCTAssertEqual(decodedTrip.title, originalTrip.title)
        XCTAssertEqual(decodedTrip.destination, originalTrip.destination)
        XCTAssertEqual(decodedTrip.imageURL, originalTrip.imageURL)
        XCTAssertEqual(decodedTrip.status, originalTrip.status)
    }
    
    func testTrip_Hashable() {
        // Given
        let id = UUID()
        let trip1 = Trip(
            id: id,
            title: "Trip 1",
            destination: "Paris",
            startDate: Date(),
            endDate: Date(),
            imageURL: "url1",
            status: .planned
        )
        
        let trip2 = Trip(
            id: id,
            title: "Trip 2",
            destination: "London",
            startDate: Date(),
            endDate: Date(),
            imageURL: "url2",
            status: .completed
        )
        
        // When
        let set = Set([trip1, trip2])
        
        // Then
        XCTAssertEqual(set.count, 1, "Trips with same ID should be considered equal")
    }
    
    func testTrip_Equatable() {
        // Given
        let id = UUID()
        let trip1 = Trip(
            id: id,
            title: "Trip 1",
            destination: "Paris",
            startDate: Date(),
            endDate: Date(),
            imageURL: "url1",
            status: .planned
        )
        
        let trip2 = Trip(
            id: id,
            title: "Trip 2",
            destination: "London",
            startDate: Date(),
            endDate: Date(),
            imageURL: "url2",
            status: .completed
        )
        
        // Then
        XCTAssertEqual(trip1, trip2, "Trips with same ID should be equal")
    }
    
    // MARK: - TripStatus Tests
    
    func testTripStatus_AllCases() {
        // Given
        let allStatuses = TripStatus.allCases
        
        // Then
        XCTAssertEqual(allStatuses.count, 3, "Should have 3 status types")
        XCTAssertTrue(allStatuses.contains(.planned))
        XCTAssertTrue(allStatuses.contains(.completed))
        XCTAssertTrue(allStatuses.contains(.ongoing))
    }
    
    func testTripStatus_RawValues() {
        // Then
        XCTAssertEqual(TripStatus.planned.rawValue, "Planned Trips")
        XCTAssertEqual(TripStatus.completed.rawValue, "Completed Trips")
        XCTAssertEqual(TripStatus.ongoing.rawValue, "Ongoing Trips")
    }
    
    func testTripStatus_Codable() throws {
        // Given
        let statuses: [TripStatus] = [.planned, .completed, .ongoing]
        
        for status in statuses {
            // When - Encode
            let encoder = JSONEncoder()
            let data = try encoder.encode(status)
            
            // Then - Decode
            let decoder = JSONDecoder()
            let decodedStatus = try decoder.decode(TripStatus.self, from: data)
            
            XCTAssertEqual(decodedStatus, status, "Status should encode and decode correctly")
        }
    }
    
    // MARK: - City Model Tests
    
    func testCity_Codable() throws {
        // Given
        let originalCity = City(
            id: UUID(),
            name: "Paris",
            country: "France",
            imageURL: "https://example.com/paris.jpg"
        )
        
        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCity)
        
        // Then - Decode
        let decoder = JSONDecoder()
        let decodedCity = try decoder.decode(City.self, from: data)
        
        XCTAssertEqual(decodedCity.id, originalCity.id)
        XCTAssertEqual(decodedCity.city, originalCity.city)
        XCTAssertEqual(decodedCity.country, originalCity.country)
        XCTAssertEqual(decodedCity.imageURL, originalCity.imageURL)
    }
    
    func testCity_PropertiesNotEmpty() {
        // Given
        let city = City(
            id: UUID(),
            name: "Tokyo",
            country: "Japan",
            imageURL: "https://example.com/tokyo.jpg"
        )
        
        // Then
        XCTAssertFalse(city.id.uuidString.isEmpty)
        XCTAssertFalse(city.city.isEmpty)
        XCTAssertFalse(city.country.isEmpty)
        XCTAssertFalse(city.imageURL.isEmpty)
    }
    
    // MARK: - NetworkError Tests
    
    func testNetworkError_ErrorDescriptions() {
        // Given
        let errors: [NetworkError] = [
            .invalidURL,
            .noData,
            .decodingError(NSError(domain: "test", code: 0)),
            .serverError(404),
            .unknown(NSError(domain: "test", code: 0))
        ]
        
        // Then
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error should have description")
            XCTAssertFalse(error.errorDescription?.isEmpty ?? true,
                          "Error description should not be empty")
        }
    }
    
    func testNetworkError_InvalidURL() {
        // Given
        let error = NetworkError.invalidURL
        
        // Then
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }
    
    func testNetworkError_NoData() {
        // Given
        let error = NetworkError.noData
        
        // Then
        XCTAssertEqual(error.errorDescription, "No data received")
    }
    
    func testNetworkError_ServerError() {
        // Given
        let error = NetworkError.serverError(404)
        
        // Then
        XCTAssertEqual(error.errorDescription, "Server error: 404")
    }
    
    func testNetworkError_DecodingError() {
        // Given
        let underlyingError = NSError(domain: "TestError", code: 100,
                                     userInfo: [NSLocalizedDescriptionKey: "Test decoding error"])
        let error = NetworkError.decodingError(underlyingError)
        
        // Then
        XCTAssertTrue(error.errorDescription?.contains("Decoding failed") ?? false)
        XCTAssertTrue(error.errorDescription?.contains("Test decoding error") ?? false)
    }
}
