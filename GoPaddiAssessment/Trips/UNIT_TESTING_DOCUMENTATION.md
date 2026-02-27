# Unit Testing Documentation

## Overview

Comprehensive unit test suite for the GoPaddi Trip Planner app, covering all major components including view models, repositories, models, navigation, and networking.

## Test Coverage

### 1. TripPlannerViewModelTests.swift

Tests the main view model that manages the app's state and business logic.

**Test Categories:**
- ✅ **Initial State Tests**: Verifies default values on initialization
- ✅ **Load Trips Tests**: Tests async trip loading functionality
- ✅ **Filter Tests**: Tests status-based filtering (Planned, Ongoing, Completed)
- ✅ **Create Trip Tests**: Tests trip creation with validation
- ✅ **Date Validation Tests**: Ensures end date is after start date
- ✅ **Error Handling Tests**: Tests error state management

**Key Test Cases:**
```swift
func testInitialState()
func testLoadTrips_Success()
func testFilteredTrips_ReturnsOnlyPlannedTrips()
func testCreateTrip_Success()
func testCreateTrip_WithEmptyCity_DoesNotCreate()
```

**Total Tests**: 13

---

### 2. TripRepositoryTests.swift

Tests the data layer, including mock repository functionality.

**Test Categories:**
- ✅ **Fetch Trips Tests**: Tests fetching all trips and filtered by status
- ✅ **Fetch Cities Tests**: Tests city data retrieval
- ✅ **Create Trip Tests**: Tests trip creation with various destinations
- ✅ **Performance Tests**: Measures operation performance

**Key Test Cases:**
```swift
func testFetchTrips_ReturnsAllTrips()
func testFetchTrips_FiltersByPlannedStatus()
func testFetchCities_ContainsExpectedCities()
func testCreateTrip_ReturnsNewTrip()
func testFetchTripsPerformance()
```

**Total Tests**: 13

---

### 3. ModelsTests.swift

Tests all data models and their computed properties.

**Test Categories:**
- ✅ **Trip Model Tests**: Duration calculation, date formatting, Codable, Hashable
- ✅ **TripStatus Tests**: Enum cases, raw values, Codable
- ✅ **City Model Tests**: Codable, data validation
- ✅ **NetworkError Tests**: Error descriptions and types

**Key Test Cases:**
```swift
func testTrip_DurationDaysCalculation()
func testTrip_FormattedStartDate()
func testTrip_Codable()
func testTrip_Hashable()
func testTripStatus_AllCases()
func testNetworkError_ErrorDescriptions()
```

**Total Tests**: 17

---

### 4. NavigationCoordinatorTests.swift

Tests the centralized navigation coordinator.

**Test Categories:**
- ✅ **Initial State Tests**: Verifies empty navigation state
- ✅ **Push Navigation Tests**: Tests push/pop operations
- ✅ **Sheet Presentation Tests**: Tests sheet presentation/dismissal
- ✅ **Full Screen Presentation Tests**: Tests full-screen modals
- ✅ **Combined Navigation Tests**: Tests multiple navigation types together
- ✅ **Navigation State Tests**: Verifies independent state management

**Key Test Cases:**
```swift
func testPush_AddsRouteToPath()
func testPop_RemovesLastRoute()
func testPopToRoot_ClearsAllRoutes()
func testPresentSheet_SetsActiveSheet()
func testDismissSheet_ClearsActiveSheet()
func testCombinedNavigation_AllTypes()
```

**Total Tests**: 21

---

### 5. HTTPClientTests.swift

Tests the networking layer with mock URLSession.

**Test Categories:**
- ✅ **API Request Tests**: Tests default protocol values
- ✅ **Fetch Request Tests**: Tests GET request construction
- ✅ **Create Request Tests**: Tests POST request with body
- ✅ **HTTP Method Tests**: Verifies HTTP method enum
- ✅ **Success Response Tests**: Tests successful API responses
- ✅ **Error Response Tests**: Tests error handling (404, decoding errors)
- ✅ **Request Construction Tests**: Tests URL and header construction

**Key Test Cases:**
```swift
func testAPIRequest_DefaultValues()
func testFetchRequest_WithStatusQueryItem()
func testCreateRequest_BodyStructure()
func testHTTPClient_SuccessfulResponse()
func testHTTPClient_ServerError()
func testHTTPClient_DecodingError()
```

**Total Tests**: 13

---

## Test Statistics

| Test File | Test Count | Coverage Area |
|-----------|-----------|---------------|
| TripPlannerViewModelTests | 13 | View Model Layer |
| TripRepositoryTests | 13 | Data/Repository Layer |
| ModelsTests | 17 | Data Models |
| NavigationCoordinatorTests | 21 | Navigation Logic |
| HTTPClientTests | 13 | Network Layer |
| **TOTAL** | **77** | **Full Stack** |

## Running Tests

### In Xcode

**Run All Tests:**
1. Press `Cmd + U`
2. Or navigate to Product → Test

**Run Specific Test File:**
1. Open the test file
2. Click the diamond icon next to the class name
3. Or press `Cmd + U` with the file open

**Run Single Test:**
1. Click the diamond icon next to the test method
2. Or place cursor in test method and press `Cmd + U`

### Command Line

```bash
# Run all tests
xcodebuild test -scheme GoPaddiAssessment -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme GoPaddiAssessment -only-testing:GoPaddiAssessmentTests/TripPlannerViewModelTests

# Run specific test method
xcodebuild test -scheme GoPaddiAssessment -only-testing:GoPaddiAssessmentTests/TripPlannerViewModelTests/testInitialState
```

## Test Architecture

### Testing Patterns Used

**1. Arrange-Act-Assert (AAA)**
```swift
func testExample() {
    // Arrange (Given)
    let sut = TripPlannerViewModel()
    
    // Act (When)
    sut.selectStatus(.planned)
    
    // Assert (Then)
    XCTAssertEqual(sut.selectedStatus, .planned)
}
```

**2. System Under Test (SUT)**
```swift
var sut: TripPlannerViewModel!

override func setUp() {
    super.setUp()
    sut = TripPlannerViewModel(repository: MockTripRepository.shared)
}

override func tearDown() {
    sut = nil
    super.tearDown()
}
```

**3. Mock Objects**
```swift
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    // Implementation...
}
```

**4. Async Testing**
```swift
func testLoadTrips_Success() async {
    await sut.loadTrips()
    XCTAssertFalse(sut.trips.isEmpty)
}
```

## Test Coverage Areas

### ✅ Covered

- [x] View Model state management
- [x] Data fetching and filtering
- [x] Trip creation and validation
- [x] Navigation push/pop/present/dismiss
- [x] Model encoding/decoding
- [x] Model computed properties
- [x] Network request construction
- [x] Network response handling
- [x] Network error handling
- [x] Repository mock data
- [x] Date calculations
- [x] Status filtering

### 🔄 Potential Additional Coverage

- [ ] UIViewController lifecycle tests
- [ ] SwiftUI View snapshot tests
- [ ] Integration tests between layers
- [ ] UI interaction tests
- [ ] Accessibility tests
- [ ] Localization tests
- [ ] Memory leak tests
- [ ] Thread safety tests

## CI/CD Integration

### GitHub Actions Example

```yaml
name: iOS Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -switch /Applications/Xcode_15.0.app
    
    - name: Run tests
      run: xcodebuild test -scheme GoPaddiAssessment -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
    
    - name: Generate coverage report
      run: xcrun llvm-cov report
```

## Best Practices Followed

### 1. Test Naming
✅ Clear, descriptive names following pattern: `test[UnitOfWork]_[StateUnderTest]_[ExpectedBehavior]`

```swift
func testCreateTrip_WithEmptyCity_DoesNotCreate()
func testFetchTrips_FiltersByPlannedStatus()
```

### 2. Test Independence
✅ Each test is independent and can run in any order

```swift
override func setUp() {
    super.setUp()
    sut = TripPlannerViewModel()
}

override func tearDown() {
    sut = nil
    super.tearDown()
}
```

### 3. Single Responsibility
✅ Each test verifies one behavior

```swift
func testInitialState() {
    XCTAssertTrue(sut.trips.isEmpty)
    XCTAssertEqual(sut.selectedStatus, .planned)
}
```

### 4. Explicit Assertions
✅ Clear assertion messages

```swift
XCTAssertEqual(sut.trips.count, initialCount + 1, "Should add new trip")
XCTAssertTrue(filtered.allSatisfy { $0.status == .planned }, "All trips should be planned")
```

### 5. Mock Dependencies
✅ Using mock repositories for isolated testing

```swift
mockRepository = MockTripRepository.shared
sut = TripPlannerViewModel(repository: mockRepository)
```

## Performance Testing

Performance tests are included to ensure operations complete within acceptable timeframes:

```swift
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
```

## Test Maintenance

### Adding New Tests

1. **Create test file**: `[Feature]Tests.swift`
2. **Import required modules**:
   ```swift
   import XCTest
   @testable import GoPaddiAssessment
   ```
3. **Create test class**: Inherit from `XCTestCase`
4. **Add setUp/tearDown**: Initialize/cleanup test dependencies
5. **Write tests**: Follow AAA pattern
6. **Run and verify**: Ensure all tests pass

### Updating Tests

- Update tests when business logic changes
- Add tests for new features
- Remove tests for deprecated features
- Refactor tests to maintain readability

## Debugging Failed Tests

### Common Issues

**1. Async Test Failures**
```swift
// ❌ Wrong
func testAsync() {
    Task { await sut.loadTrips() }
    XCTAssertFalse(sut.trips.isEmpty) // May fail due to timing
}

// ✅ Correct
func testAsync() async {
    await sut.loadTrips()
    XCTAssertFalse(sut.trips.isEmpty)
}
```

**2. Test Isolation**
```swift
// ❌ Wrong - Shared state between tests
static var sut: ViewModel!

// ✅ Correct - Isolated state
var sut: ViewModel!
override func setUp() {
    sut = ViewModel()
}
```

**3. Floating Point Comparison**
```swift
// ❌ Wrong
XCTAssertEqual(date1.timeIntervalSince1970, date2.timeIntervalSince1970)

// ✅ Correct
XCTAssertEqual(date1.timeIntervalSince1970, date2.timeIntervalSince1970, accuracy: 1.0)
```

## Code Coverage

To view code coverage in Xcode:

1. Enable code coverage: Edit Scheme → Test → Options → Code Coverage ✅
2. Run tests: `Cmd + U`
3. View coverage: Show Report Navigator (Cmd + 9) → Select Coverage tab

**Target Coverage**: Aim for >80% code coverage on testable components

## Summary

The test suite provides comprehensive coverage of the app's core functionality:
- ✅ 77 unit tests across 5 test files
- ✅ Tests all major architectural layers
- ✅ Follows industry best practices
- ✅ Enables confident refactoring and feature additions
- ✅ Ready for CI/CD integration

**Next Steps:**
1. Run all tests to ensure they pass: `Cmd + U`
2. Add test target to Xcode project if not already present
3. Enable code coverage in scheme settings
4. Set up CI/CD pipeline with automated testing
5. Maintain tests as features are added/modified
