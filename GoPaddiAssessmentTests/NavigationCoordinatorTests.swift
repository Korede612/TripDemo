//
//  NavigationCoordinatorTests.swift
//  GoPaddiAssessmentTests
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import XCTest
import SwiftUI
@testable import GoPaddiAssessment

@MainActor
final class NavigationCoordinatorTests: XCTestCase {
    
    var sut: NavigationCoordinator!
    
    override func setUp() {
        super.setUp()
        sut = NavigationCoordinator()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Then
        XCTAssertTrue(sut.path.isEmpty, "Path should be empty initially")
        XCTAssertNil(sut.activeSheet, "Active sheet should be nil initially")
        XCTAssertNil(sut.activeFullScreen, "Active full screen should be nil initially")
    }
    
    // MARK: - Push Navigation Tests
    
    func testPush_AddsRouteToPath() {
        // Given
        let route = AppRoute.countryList
        
        // When
        sut.push(route)
        
        // Then
        XCTAssertEqual(sut.path.count, 1, "Path should have one item")
    }
    
    func testPush_MultipleRoutes() {
        // Given
        let routes: [AppRoute] = [
            .countryList,
            .countryDetail(code: "US"),
            .tripCreate
        ]
        
        // When
        for route in routes {
            sut.push(route)
        }
        
        // Then
        XCTAssertEqual(sut.path.count, routes.count,
                      "Path should have \(routes.count) items")
    }
    
    // MARK: - Pop Navigation Tests
    
    func testPop_RemovesLastRoute() {
        // Given
        sut.push(.countryList)
        sut.push(.countryDetail(code: "US"))
        XCTAssertEqual(sut.path.count, 2)
        
        // When
        sut.pop()
        
        // Then
        XCTAssertEqual(sut.path.count, 1, "Path should have one item after pop")
    }
    
    func testPop_OnEmptyPath_DoesNothing() {
        // Given
        XCTAssertTrue(sut.path.isEmpty)
        
        // When
        sut.pop()
        
        // Then
        XCTAssertTrue(sut.path.isEmpty, "Path should remain empty")
    }
    
    func testPopToRoot_ClearsAllRoutes() {
        // Given
        sut.push(.countryList)
        sut.push(.countryDetail(code: "US"))
        sut.push(.tripCreate)
        XCTAssertEqual(sut.path.count, 3)
        
        // When
        sut.popToRoot()
        
        // Then
        XCTAssertTrue(sut.path.isEmpty, "Path should be empty after pop to root")
    }
    
    func testPopToRoot_OnEmptyPath_DoesNothing() {
        // Given
        XCTAssertTrue(sut.path.isEmpty)
        
        // When
        sut.popToRoot()
        
        // Then
        XCTAssertTrue(sut.path.isEmpty, "Path should remain empty")
    }
    
    // MARK: - Sheet Presentation Tests
    
    func testPresentSheet_SetsActiveSheet() {
        // Given
        let route = AppRoute.tripCreate
        
        // When
        sut.presentSheet(route)
        
        // Then
        XCTAssertNotNil(sut.activeSheet, "Active sheet should not be nil")
        XCTAssertEqual(sut.activeSheet, route, "Active sheet should match presented route")
    }
    
    func testPresentSheet_ReplacesExistingSheet() {
        // Given
        sut.presentSheet(.tripCreate)
        XCTAssertNotNil(sut.activeSheet)
        
        // When
        sut.presentSheet(.countryList)
        
        // Then
        XCTAssertEqual(sut.activeSheet, .countryList,
                      "Active sheet should be replaced with new route")
    }
    
    func testDismissSheet_ClearsActiveSheet() {
        // Given
        sut.presentSheet(.tripCreate)
        XCTAssertNotNil(sut.activeSheet)
        
        // When
        sut.dismissSheet()
        
        // Then
        XCTAssertNil(sut.activeSheet, "Active sheet should be nil after dismiss")
    }
    
    func testDismissSheet_WhenNoSheet_DoesNothing() {
        // Given
        XCTAssertNil(sut.activeSheet)
        
        // When
        sut.dismissSheet()
        
        // Then
        XCTAssertNil(sut.activeSheet, "Active sheet should remain nil")
    }
    
    // MARK: - Full Screen Presentation Tests
    
    func testPresentFullScreen_SetsActiveFullScreen() {
        // Given
        let route = AppRoute.countryList
        
        // When
        sut.presentFullScreen(route)
        
        // Then
        XCTAssertNotNil(sut.activeFullScreen, "Active full screen should not be nil")
        XCTAssertEqual(sut.activeFullScreen, route,
                      "Active full screen should match presented route")
    }
    
    func testPresentFullScreen_ReplacesExisting() {
        // Given
        sut.presentFullScreen(.countryList)
        XCTAssertNotNil(sut.activeFullScreen)
        
        // When
        sut.presentFullScreen(.tripCreate)
        
        // Then
        XCTAssertEqual(sut.activeFullScreen, .tripCreate,
                      "Active full screen should be replaced")
    }
    
    func testDismissFullScreen_ClearsActiveFullScreen() {
        // Given
        sut.presentFullScreen(.countryList)
        XCTAssertNotNil(sut.activeFullScreen)
        
        // When
        sut.dismissFullScreen()
        
        // Then
        XCTAssertNil(sut.activeFullScreen,
                    "Active full screen should be nil after dismiss")
    }
    
    func testDismissFullScreen_WhenNone_DoesNothing() {
        // Given
        XCTAssertNil(sut.activeFullScreen)
        
        // When
        sut.dismissFullScreen()
        
        // Then
        XCTAssertNil(sut.activeFullScreen, "Active full screen should remain nil")
    }
    
    // MARK: - Combined Navigation Tests
    
    func testCombinedNavigation_PushAndSheet() {
        // Given & When
        sut.push(.countryList)
        sut.presentSheet(.tripCreate)
        
        // Then
        XCTAssertEqual(sut.path.count, 1, "Should have one pushed route")
        XCTAssertNotNil(sut.activeSheet, "Should have active sheet")
        XCTAssertNil(sut.activeFullScreen, "Should have no full screen")
    }
    
    func testCombinedNavigation_AllTypes() {
        // Given & When
        sut.push(.countryList)
        sut.push(.countryDetail(code: "US"))
        sut.presentSheet(.tripCreate)
        
        // Then
        XCTAssertEqual(sut.path.count, 2, "Should have two pushed routes")
        XCTAssertNotNil(sut.activeSheet, "Should have active sheet")
    }
    
    func testCombinedNavigation_ClearAll() {
        // Given
        sut.push(.countryList)
        sut.presentSheet(.tripCreate)
        sut.presentFullScreen(.countryDetail(code: "US"))
        
        // When
        sut.popToRoot()
        sut.dismissSheet()
        sut.dismissFullScreen()
        
        // Then
        XCTAssertTrue(sut.path.isEmpty, "Path should be empty")
        XCTAssertNil(sut.activeSheet, "Sheet should be nil")
        XCTAssertNil(sut.activeFullScreen, "Full screen should be nil")
    }
    
    // MARK: - Navigation State Tests
    
    func testNavigationState_IndependentOfEachOther() {
        // Given & When
        sut.presentSheet(.tripCreate)
        
        // Then
        XCTAssertNotNil(sut.activeSheet, "Sheet should be set")
        XCTAssertTrue(sut.path.isEmpty, "Path should remain empty")
        XCTAssertNil(sut.activeFullScreen, "Full screen should remain nil")
        
        // When
        sut.push(.countryList)
        
        // Then
        XCTAssertNotNil(sut.activeSheet, "Sheet should still be set")
        XCTAssertEqual(sut.path.count, 1, "Path should have one item")
        XCTAssertNil(sut.activeFullScreen, "Full screen should remain nil")
    }
}
