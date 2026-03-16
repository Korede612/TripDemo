//
//  TripRepositoryTests.swift
//  GoPaddiAssessmentTests
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import XCTest
@testable import GoPaddiAssessment

final class TripRepositoryTests: XCTestCase {
    
    var sut: MockTripRepository!
    
    override func setUp() {
        super.setUp()
        sut = MockTripRepository.shared
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Trips Tests
    
    func testFetchTrips_ReturnsAllTrips() async throws {
        // When
        let trips = try await sut.fetchTrips(status: nil)
        
        // Then
        XCTAssertFalse(trips.isEmpty, "Should return trips")
        XCTAssertGreaterThan(trips.count, 0, "Should have at least one trip")
    }
    
    func testFetchTrips_FiltersByPlannedStatus() async throws {
        // When
        let trips = try await sut.fetchTrips(status: .planned)
        
        // Then
        XCTAssertFalse(trips.isEmpty, "Should return planned trips")
        XCTAssertTrue(trips.allSatisfy { $0.status == .planned },
                     "All trips should have planned status")
    }
    
    func testFetchTrips_FiltersByCompletedStatus() async throws {
        // When
        let trips = try await sut.fetchTrips(status: .completed)
        
        // Then
        XCTAssertTrue(trips.allSatisfy { $0.status == .completed },
                     "All trips should have completed status")
    }
    
    func testFetchTrips_FiltersByOngoingStatus() async throws {
        // When
        let trips = try await sut.fetchTrips(status: .ongoing)
        
        // Then
        XCTAssertTrue(trips.allSatisfy { $0.status == .ongoing },
                     "All trips should have ongoing status")
    }
    
    func testFetchTrips_ReturnsValidTripData() async throws {
        // When
        let trips = try await sut.fetchTrips(status: nil)
        
        // Then
        for trip in trips {
            XCTAssertFalse(trip.id.uuidString.isEmpty, "Trip should have valid ID")
            XCTAssertFalse(trip.title.isEmpty, "Trip should have title")
            XCTAssertFalse(trip.destination.isEmpty, "Trip should have destination")
            XCTAssertFalse(trip.imageURL.isEmpty, "Trip should have image URL")
            XCTAssertLessThanOrEqual(trip.startDate, trip.endDate,
                                    "Start date should be before or equal to end date")
        }
    }
    
    // MARK: - Fetch Cities Tests
    
    func testFetchCities_ReturnsCities() async throws {
        // When
        let cities = try await sut.fetchCities()
        
        // Then
        XCTAssertFalse(cities.isEmpty, "Should return cities")
        XCTAssertGreaterThan(cities.count, 0, "Should have at least one city")
    }
    
    func testFetchCities_ReturnsValidCityData() async throws {
        // When
        let cities = try await sut.fetchCities()
        
        // Then
        for city in cities {
            XCTAssertFalse(city.id.uuidString.isEmpty, "City should have valid ID")
            XCTAssertFalse(city.city.isEmpty, "City should have name")
            XCTAssertFalse(city.country.isEmpty, "City should have country")
        }
    }
    
    func testFetchCities_ContainsExpectedCities() async throws {
        // When
        let cities = try await sut.fetchCities()
        let cityNames = cities.map { $0.city }
        
        // Then
        XCTAssertTrue(cityNames.contains("Paris"), "Should contain Paris")
        XCTAssertTrue(cityNames.contains("Tokyo"), "Should contain Tokyo")
        XCTAssertTrue(cityNames.contains("New York"), "Should contain New York")
    }
    
    // MARK: - Create Trip Tests
    
    func testCreateTrip_ReturnsNewTrip() async throws {
        // Given
        let destination = "Paris"
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 5, to: startDate)!
        
        // When
        let trip = try await sut.createTrip(
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        
        // Then
        XCTAssertFalse(trip.id.uuidString.isEmpty, "Trip should have valid ID")
        XCTAssertTrue(trip.title.contains(destination), "Trip title should contain destination")
        XCTAssertEqual(trip.destination, destination, "Trip destination should match")
        XCTAssertEqual(trip.startDate, startDate, "Start date should match")
        XCTAssertEqual(trip.endDate, endDate, "End date should match")
        XCTAssertEqual(trip.status, .planned, "New trip should have planned status")
    }
    
    func testCreateTrip_WithDifferentDestinations() async throws {
        // Given
        let destinations = ["London", "Berlin", "Madrid"]
        
        for destination in destinations {
            // When
            let trip = try await sut.createTrip(
                destination: destination,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!
            )
            
            // Then
            XCTAssertEqual(trip.destination, destination,
                          "Trip destination should match \(destination)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testFetchTripsPerformance() {
        measure {
            let expectation = expectation(description: "Fetch trips")
            
            Task {
                _ = try await sut.fetchTrips(status: nil)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    func testFetchCitiesPerformance() {
        measure {
            let expectation = expectation(description: "Fetch cities")
            
            Task {
                _ = try await sut.fetchCities()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    func testCreateTripPerformance() {
        measure {
            let expectation = expectation(description: "Create trip")
            
            Task {
                _ = try await sut.createTrip(
                    destination: "Test",
                    startDate: Date(),
                    endDate: Date()
                )
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
}
