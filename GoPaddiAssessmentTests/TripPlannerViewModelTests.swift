//
//  TripPlannerViewModelTests.swift
//  GoPaddiAssessmentTests
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import XCTest
@testable import GoPaddiAssessment

@MainActor
final class TripPlannerViewModelTests: XCTestCase {
    
    var sut: TripPlannerViewModel!
    var mockRepository: MockTripRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTripRepository.shared
        sut = TripPlannerViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Given & When - initialized in setUp
        
        // Then
        XCTAssertTrue(sut.trips.isEmpty, "Trips should be empty initially")
        XCTAssertEqual(sut.selectedStatus, .planned, "Default status should be planned")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.errorMessage, "Should have no error initially")
        XCTAssertTrue(sut.selectedCity.isEmpty, "City should be empty initially")
        XCTAssertFalse(sut.isCreatingTrip, "Should not be creating trip initially")
    }
    
    // MARK: - Load Trips Tests
    
    func testLoadTrips_Success() async {
        // Given
        XCTAssertTrue(sut.trips.isEmpty)
        
        // When
        await sut.loadTrips()
        
        // Then
        XCTAssertFalse(sut.trips.isEmpty, "Trips should be loaded")
        XCTAssertFalse(sut.isLoading, "Loading should be complete")
        XCTAssertNil(sut.errorMessage, "Should have no error")
        XCTAssertGreaterThan(sut.trips.count, 0, "Should have at least one trip")
    }
    
    func testLoadTrips_SetsLoadingStateCorrectly() async {
        // Given
        XCTAssertFalse(sut.isLoading)
        
        // When
        let loadTask = Task {
            await sut.loadTrips()
        }
        
        // Then - loading state might be too fast to catch, but we verify end state
        await loadTask.value
        XCTAssertFalse(sut.isLoading, "Loading should be false after completion")
    }
    
    // MARK: - Filter Tests
    
    func testFilteredTrips_ReturnsOnlyPlannedTrips() async {
        // Given
        await sut.loadTrips()
        sut.selectStatus(.planned)
        
        // When
        let filtered = sut.filteredTrips
        
        // Then
        XCTAssertFalse(filtered.isEmpty, "Should have planned trips")
        XCTAssertTrue(filtered.allSatisfy { $0.status == .planned }, "All trips should be planned")
    }
    
    func testFilteredTrips_ReturnsOnlyCompletedTrips() async {
        // Given
        await sut.loadTrips()
        sut.selectStatus(.completed)
        
        // When
        let filtered = sut.filteredTrips
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.status == .completed }, "All trips should be completed")
    }
    
    func testFilteredTrips_ReturnsOnlyOngoingTrips() async {
        // Given
        await sut.loadTrips()
        sut.selectStatus(.ongoing)
        
        // When
        let filtered = sut.filteredTrips
        
        // Then
        XCTAssertTrue(filtered.allSatisfy { $0.status == .ongoing }, "All trips should be ongoing")
    }
    
    func testSelectStatus_UpdatesSelectedStatus() {
        // Given
        XCTAssertEqual(sut.selectedStatus, .planned)
        
        // When
        sut.selectStatus(.completed)
        
        // Then
        XCTAssertEqual(sut.selectedStatus, .completed, "Status should be updated to completed")
        
        // When
        sut.selectStatus(.ongoing)
        
        // Then
        XCTAssertEqual(sut.selectedStatus, .ongoing, "Status should be updated to ongoing")
    }
    
    // MARK: - Create Trip Tests
    
    func testCreateTrip_Success() async {
        // Given
        await sut.loadTrips()
        let initialCount = sut.trips.count
        sut.selectedCity = "Paris"
        sut.startDate = Date()
        sut.endDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        // When
        await sut.createTrip()
        
        // Then
        XCTAssertEqual(sut.trips.count, initialCount + 1, "Should add new trip")
        XCTAssertTrue(sut.selectedCity.isEmpty, "City should be cleared after creation")
        XCTAssertFalse(sut.isCreatingTrip, "Should not be creating trip after completion")
        XCTAssertNil(sut.errorMessage, "Should have no error")
    }
    
    func testCreateTrip_WithEmptyCity_DoesNotCreate() async {
        // Given
        await sut.loadTrips()
        let initialCount = sut.trips.count
        sut.selectedCity = ""
        sut.startDate = Date()
        sut.endDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        // When
        await sut.createTrip()
        
        // Then
        XCTAssertEqual(sut.trips.count, initialCount, "Should not add new trip")
    }
    
    func testCreateTrip_InsertsAtBeginning() async {
        // Given
        await sut.loadTrips()
        sut.selectedCity = "New Destination"
        sut.startDate = Date()
        sut.endDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        
        // When
        await sut.createTrip()
        
        // Then
        XCTAssertTrue(sut.trips.first?.destination.contains("New Destination") ?? false,
                     "New trip should be at the beginning")
    }
    
    // MARK: - Date Validation Tests
    
    func testDates_EndDateAfterStartDate() {
        // Given
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 5, to: startDate)!
        
        // When
        sut.startDate = startDate
        sut.endDate = endDate
        
        // Then
        XCTAssertLessThan(sut.startDate, sut.endDate, "End date should be after start date")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessage_InitiallyNil() {
        // Then
        XCTAssertNil(sut.errorMessage, "Error message should be nil initially")
    }
    
    func testErrorMessage_ClearedOnSuccessfulLoad() async {
        // Given
        sut.errorMessage = "Some error"
        
        // When
        await sut.loadTrips()
        
        // Then
        XCTAssertNil(sut.errorMessage, "Error message should be cleared on successful load")
    }
}
