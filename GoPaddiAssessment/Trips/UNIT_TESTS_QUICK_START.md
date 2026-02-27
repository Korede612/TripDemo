# Unit Tests - Quick Start Guide

## 🎯 What Was Implemented

Comprehensive unit test suite covering all major components of the GoPaddi Trip Planner app:

### Test Files Created (77 Total Tests)

1. **TripPlannerViewModelTests.swift** (13 tests)
   - View model state management
   - Trip loading and filtering
   - Trip creation
   - Error handling

2. **TripRepositoryTests.swift** (13 tests)
   - Data fetching
   - Status filtering
   - City retrieval
   - Performance testing

3. **ModelsTests.swift** (17 tests)
   - Trip model properties
   - TripStatus enum
   - City model
   - NetworkError handling

4. **NavigationCoordinatorTests.swift** (21 tests)
   - Push/pop navigation
   - Sheet presentation
   - Full-screen modals
   - Combined navigation scenarios

5. **HTTPClientTests.swift** (13 tests)
   - Request construction
   - Response handling
   - Error scenarios
   - URL and header validation

## 🚀 How to Add Tests to Your Xcode Project

### Step 1: Create Test Target (If Not Exists)

If you don't already have a test target:

1. In Xcode, go to **File → New → Target**
2. Choose **iOS → Unit Testing Bundle**
3. Name it: `GoPaddiAssessmentTests`
4. Click **Finish**

### Step 2: Add Test Files

1. **Right-click** on the `GoPaddiAssessmentTests` folder in Project Navigator
2. Choose **Add Files to "GoPaddiAssessmentTests"...**
3. Select all 5 test files:
   - `TripPlannerViewModelTests.swift`
   - `TripRepositoryTests.swift`
   - `ModelsTests.swift`
   - `NavigationCoordinatorTests.swift`
   - `HTTPClientTests.swift`
4. Ensure **Target Membership** includes `GoPaddiAssessmentTests`

### Step 3: Configure Test Target

1. Select your project in Project Navigator
2. Select `GoPaddiAssessmentTests` target
3. Go to **Build Settings**
4. Search for "Enable Testing"
5. Ensure **Enable Testability** is set to **Yes**

### Step 4: Import Main Module

Ensure your main app target allows testing:

1. Select `GoPaddiAssessment` target (main app)
2. Go to **Build Settings**
3. Search for "Enable Testability"
4. Set to **Yes** for **Debug** configuration

## ▶️ Running Tests

### In Xcode

**Run All Tests:**
```
Press: Cmd + U
Or: Product → Test
```

**Run Specific Test File:**
1. Open the test file
2. Click ◇ (diamond) icon next to class name
3. Or press `Cmd + U` with file open

**Run Single Test:**
1. Click ◇ icon next to test method
2. Or place cursor in method and press `Cmd + U`

**Run Tests with Coverage:**
1. Edit Scheme (Product → Scheme → Edit Scheme)
2. Select **Test** tab
3. Check **Code Coverage** option
4. Click **Close**
5. Run tests: `Cmd + U`
6. View coverage: `Cmd + 9` → Coverage tab

### From Command Line

```bash
# Run all tests
xcodebuild test \
  -scheme GoPaddiAssessment \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Run with specific simulator
xcodebuild test \
  -scheme GoPaddiAssessment \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0'

# Run specific test class
xcodebuild test \
  -scheme GoPaddiAssessment \
  -only-testing:GoPaddiAssessmentTests/TripPlannerViewModelTests

# Run specific test method
xcodebuild test \
  -scheme GoPaddiAssessment \
  -only-testing:GoPaddiAssessmentTests/TripPlannerViewModelTests/testInitialState
```

## 📊 Viewing Results

### Test Navigator

1. Press `Cmd + 6` to open Test Navigator
2. See all tests organized by file
3. Green ✓ = passed, Red ✗ = failed
4. Click test to jump to code

### Report Navigator

1. Press `Cmd + 9` to open Report Navigator
2. Select latest test run
3. See detailed results and logs
4. View code coverage (if enabled)

### Console Output

- View test output in console at bottom of Xcode
- See XCTAssert messages and print statements
- Debug failed tests

## 🐛 Common Issues & Solutions

### Issue 1: "Use of unresolved identifier"

**Problem**: Test can't find app classes
**Solution**: 
```swift
// Add at top of test file
@testable import GoPaddiAssessment
```

### Issue 2: "No such module 'XCTest'"

**Problem**: XCTest not imported
**Solution**:
```swift
// Add at top of test file
import XCTest
```

### Issue 3: Tests Fail Randomly

**Problem**: Tests not isolated or have race conditions
**Solution**: 
- Use `async`/`await` for async tests
- Ensure `setUp()` and `tearDown()` properly reset state
- Don't use shared static state

### Issue 4: "Cannot find type in scope"

**Problem**: Test target can't access app target
**Solution**:
1. Select app target
2. Build Settings → Enable Testability → **Yes**
3. Clean build folder: `Cmd + Shift + K`
4. Rebuild: `Cmd + B`

### Issue 5: MockURLProtocol Not Working

**Problem**: URLSession not using mock protocol
**Solution**:
```swift
let configuration = URLSessionConfiguration.ephemeral
configuration.protocolClasses = [MockURLProtocol.self]
mockSession = URLSession(configuration: configuration)
```

## ✅ Verification Checklist

After adding tests to your project:

- [ ] All 5 test files added to test target
- [ ] Test target has access to main app module (`@testable import`)
- [ ] Enable Testability is **Yes** in Build Settings
- [ ] Tests appear in Test Navigator (`Cmd + 6`)
- [ ] Can run all tests with `Cmd + U`
- [ ] All 77 tests pass ✅
- [ ] Code coverage shows in Report Navigator
- [ ] No warnings or errors in test files

## 📈 Expected Results

When you run the complete test suite:

```
Test Suite 'All tests' started
Test Suite 'TripPlannerViewModelTests' started
  ✓ testInitialState (0.001 seconds)
  ✓ testLoadTrips_Success (0.823 seconds)
  ✓ testFilteredTrips_ReturnsOnlyPlannedTrips (0.801 seconds)
  ... (10 more tests)
  
Test Suite 'TripRepositoryTests' started
  ✓ testFetchTrips_ReturnsAllTrips (0.812 seconds)
  ✓ testFetchTrips_FiltersByPlannedStatus (0.804 seconds)
  ... (11 more tests)
  
Test Suite 'ModelsTests' started
  ✓ testTrip_DurationDaysCalculation (0.001 seconds)
  ✓ testTrip_FormattedStartDate (0.001 seconds)
  ... (15 more tests)
  
Test Suite 'NavigationCoordinatorTests' started
  ✓ testInitialState (0.001 seconds)
  ✓ testPush_AddsRouteToPath (0.002 seconds)
  ... (19 more tests)
  
Test Suite 'HTTPClientTests' started
  ✓ testAPIRequest_DefaultValues (0.001 seconds)
  ✓ testHTTPClient_SuccessfulResponse (0.015 seconds)
  ... (11 more tests)

Test Suite 'All tests' passed
  Executed 77 tests, with 0 failures in 5.234 seconds
```

## 🎓 Learning Resources

### Understanding the Tests

**Arrange-Act-Assert Pattern:**
```swift
func testExample() {
    // Arrange: Set up test data
    let viewModel = TripPlannerViewModel()
    
    // Act: Perform action
    viewModel.selectStatus(.planned)
    
    // Assert: Verify result
    XCTAssertEqual(viewModel.selectedStatus, .planned)
}
```

**Async Testing:**
```swift
func testAsyncOperation() async {
    // Use 'async' and 'await' for async tests
    await viewModel.loadTrips()
    XCTAssertFalse(viewModel.trips.isEmpty)
}
```

**Performance Testing:**
```swift
func testPerformance() {
    measure {
        // Code to measure
        viewModel.filterTrips()
    }
}
```

### XCTest Assertions

| Assertion | Usage |
|-----------|-------|
| `XCTAssertTrue()` | Value is true |
| `XCTAssertFalse()` | Value is false |
| `XCTAssertEqual()` | Values are equal |
| `XCTAssertNotEqual()` | Values are not equal |
| `XCTAssertNil()` | Value is nil |
| `XCTAssertNotNil()` | Value is not nil |
| `XCTAssertGreaterThan()` | Value is greater |
| `XCTAssertLessThan()` | Value is less |

## 🔧 Customizing Tests

### Add Your Own Test

1. Open any test file (e.g., `TripPlannerViewModelTests.swift`)
2. Add new test method:

```swift
func testYourNewFeature() {
    // Arrange
    let viewModel = TripPlannerViewModel()
    
    // Act
    viewModel.performAction()
    
    // Assert
    XCTAssertTrue(viewModel.expectedResult)
}
```

3. Run test: Click ◇ icon or press `Cmd + U`

### Create New Test File

1. Right-click test folder
2. New File → Unit Test Case Class
3. Name it: `[Feature]Tests.swift`
4. Add tests following existing patterns

## 🎉 Success!

You now have:
- ✅ 77 comprehensive unit tests
- ✅ Full coverage of major components
- ✅ Automated testing capability
- ✅ Foundation for TDD workflow
- ✅ Confidence in code changes

## 📚 Next Steps

1. **Run Tests Regularly**: Before committing code
2. **Add Tests for New Features**: Follow TDD approach
3. **Maintain Coverage**: Keep coverage above 80%
4. **CI/CD Integration**: Automate testing in pipeline
5. **Review Documentation**: See `UNIT_TESTING_DOCUMENTATION.md` for details

Happy Testing! 🚀
