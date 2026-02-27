# GoPaddi Trip Planner

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg" alt="Platform: iOS 15.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/Architecture-MVVM-green.svg" alt="Architecture: MVVM">
</p>

A modern iOS trip planning application built with SwiftUI and UIKit, featuring a clean MVVM architecture, protocol-based networking, and a comprehensive trip management system.

## 📱 Features

### Trip Management
- **Create Trips**: Build personalized trip itineraries with destination, dates, and details
- **View Trips**: Browse your trips with beautiful card-based UI
- **Filter Trips**: Filter by status (Planned, Ongoing, Completed)
- **Trip Details**: View comprehensive trip information including activities, hotels, flights, and itineraries

### User Interface
- **Hero Header**: Eye-catching gradient header with booking form
- **City Selection**: Interactive city picker with search functionality
- **Date Selection**: Custom date picker with validation (no past dates, end after start)
- **Status Dropdown**: Animated expandable dropdown for filtering trips
- **Shimmer Loading**: Beautiful skeleton loading states with shimmer effects
- **Empty States**: Informative empty and error states
- **Trip Cards**: Rich trip cards with images, dates, and status badges

### Navigation
- **Coordinated Navigation**: Centralized navigation using `NavigationCoordinator`
- **Multiple Presentation Styles**: Support for push, sheet, and full-screen presentations
- **Dynamic Sheet Heights**: Context-aware sheet sizing for optimal UX
- **Deep Linking Ready**: Route-based navigation system

## 🏗 Architecture

### MVVM + Repository Pattern + Coordinator

```
┌─────────────────────────────────────────────────────────┐
│                         Views                           │
│  (SwiftUI & UIKit - Declarative & Imperative UI)       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├─ Bindings (@Published, Combine)
                 │
┌────────────────▼────────────────────────────────────────┐
│                      View Models                        │
│  (@MainActor ObservableObjects - Business Logic)       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├─ Protocol Abstraction
                 │
┌────────────────▼────────────────────────────────────────┐
│                     Repositories                        │
│  (Data Layer - API/Mock Data Management)               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ├─ HTTP Client Protocol
                 │
┌────────────────▼────────────────────────────────────────┐
│                    Network Layer                        │
│  (URLSession-based HTTP Client)                        │
└─────────────────────────────────────────────────────────┘
```

### Key Components

#### Navigation System
- **NavigationCoordinator**: Centralized navigation state management
- **AppRoutes**: Type-safe routing enum for all app destinations
- **AppNavigationRoot**: SwiftUI NavigationStack integration
- **Dynamic Detents**: Context-aware sheet presentation sizes

#### View Layer
- **TripPlannerViewController**: Main UIKit screen (trip list)
- **TripDetailsViewController**: Full trip details view
- **CountryListView**: City/country selection
- **TripCreateViewController**: Trip creation form
- **DatePickerViewController**: Custom date range picker
- **HeroHeaderView**: Hero section with booking form

#### View Model Layer
- **TripPlannerViewModel**: Main app state (@Published properties)
- Uses Swift Concurrency (async/await)
- Reactive updates via Combine

#### Data Layer
- **TripRepositoryProtocol**: Abstracts data source
- **MockTripRepository**: In-memory mock data for development
- **TripRepository**: Live API implementation (ready for backend)
- **HTTPClient**: Protocol-based network client

## 📂 Project Structure

```
GoPaddiAssessment/
│
├── App/
│   ├── AppNavigationRoot.swift           # Navigation root
│   ├── AppRoutes.swift                   # Route definitions
│   └── NavigationCoordinator.swift       # Navigation coordinator
│
├── Models/
│   └── Models.swift                      # Trip, City, Status models
│
├── Network/
│   ├── HTTPClient.swift                  # HTTP client protocol
│   ├── TripRepository.swift              # Repository implementation
│   └── MockTripRepository.swift          # Mock data provider
│
├── ViewModels/
│   └── TripPlannerViewModel.swift        # Main view model
│
├── Views/
│   ├── Main/
│   │   ├── TripPlannerViewController.swift          # Main screen
│   │   ├── TripPlannerRootView.swift               # SwiftUI wrapper
│   │   └── HeroHeaderView.swift                    # Hero section
│   │
│   ├── TripDetails/
│   │   ├── TripDetailsViewController.swift         # Trip details
│   │   └── TripDetailsViewControllerRepresentable  # SwiftUI bridge
│   │
│   ├── TripCreation/
│   │   ├── TripCreateViewController.swift          # Create trip form
│   │   ├── TripCreationPresenter.swift            # Presenter wrapper
│   │   ├── DatePickerViewController.swift         # Date picker
│   │   └── CityPickerViewController.swift         # City picker
│   │
│   ├── Country/
│   │   ├── CountryListView.swift                  # Country list
│   │   └── CountryDetailView.swift                # Country details
│   │
│   └── Components/
│       ├── TripCardCell.swift                     # Trip card cell
│       ├── StatusDropdownView.swift               # Status filter
│       └── StateView.swift                        # Empty/Error states
│
├── Helpers/
│   └── Extensions.swift                  # UI helpers, Color extensions
│
└── Documentation/
    ├── IMPLEMENTATION_SUMMARY.md         # Implementation overview
    ├── CREATE_TRIP_IMPLEMENTATION.md     # Create trip feature
    ├── TRIP_DETAILS_IMPLEMENTATION.md    # Trip details feature
    ├── DYNAMIC_SHEET_HEIGHTS.md          # Sheet configuration
    └── CHECKLIST.md                      # Development checklist
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gopaddi-assessment.git
cd gopaddi-assessment
```

2. Open the project in Xcode:
```bash
open GoPaddiAssessment.xcodeproj
```

3. Build and run:
- Select a simulator or device
- Press `Cmd + R` to build and run

### Configuration

The app currently uses mock data. To switch to a live backend:

1. Open `TripPlannerViewModel.swift`
2. Change the repository initialization:

```swift
// From Mock (default):
init(repository: TripRepositoryProtocol = MockTripRepository.shared)

// To Live API:
init(repository: TripRepositoryProtocol = TripRepository())
```

3. Update the base URL in `HTTPClient.swift`:

```swift
let baseURL: URL
init(baseURL: String = "https://your-api.com/api/v1") {
    self.baseURL = URL(string: baseURL)!
}
```

## 🎨 Design System

### Colors
```swift
Brand Blue:       #1A73E8
Background Gray:  #F2F3F5
Card Background:  #FFFFFF
Hero Top:         #E8F4F8
Hero Bottom:      #D0E8F0
Primary Blue:     #2196F3
```

### Typography
- **Headers**: System Bold, 20-24pt
- **Body**: System Regular, 13-15pt
- **Buttons**: System Semibold, 15-16pt
- **Labels**: System Medium, 11-13pt

### Spacing
- Section Spacing: 20pt
- Card Padding: 16pt
- Button Height: 44-50pt
- Corner Radius: 8-16pt

### Shadows
- Cards: Opacity 0.06-0.08, Radius 8-12, Offset (0, 2-4)
- Buttons: Opacity 0.05, Radius 4, Offset (0, 2)

## 🔑 Key Technologies

- **SwiftUI**: Declarative UI framework
- **UIKit**: Imperative UI for complex views
- **Combine**: Reactive programming for data flow
- **Swift Concurrency**: Async/await for asynchronous operations
- **Protocol-Oriented Programming**: Testable, modular architecture
- **MVVM Pattern**: Separation of concerns
- **Coordinator Pattern**: Centralized navigation

## 📱 Screens

### 1. Trip Planner (Main Screen)
- Hero section with trip creation form
- City selection
- Date range selection
- Status filter dropdown
- Trip cards list
- Loading skeletons
- Empty/error states

### 2. Trip Details
- Full-width header with trip image
- Trip information (dates, title, location)
- Collaboration and share buttons
- Activities section
- Hotels section
- Flights section
- Trip itineraries section

### 3. Create Trip
- Trip name input
- Travel style selection
- Description field
- Form validation
- Animated interactions

### 4. City Selection
- Searchable city list
- Country information
- Interactive selection

### 5. Date Picker
- Start and end date selection
- Validation (no past dates)
- Calendar interface

## 🧪 Testing

The architecture is designed for testability:

### Unit Testing
- Mock repositories for isolated testing
- Protocol-based dependencies
- Pure view models (no UIKit dependencies)

### UI Testing
- SwiftUI Preview support
- UIKit view controller representables

## 🔄 Navigation Flow

```
TripPlannerViewController (Main)
    ↓
    ├─→ CountryListView (Sheet)
    │       ↓
    │       └─→ CountryDetailView (Push)
    │
    ├─→ TripCreateViewController (Sheet)
    │       ↓
    │       └─→ DatePickerViewController (Sheet)
    │
    └─→ TripDetailsViewController (Push)
            ↓
            ├─→ Activities (Future)
            ├─→ Hotels (Future)
            ├─→ Flights (Future)
            └─→ Itineraries (Future)
```

## 🎯 Data Models

### Trip
```swift
struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let imageURL: String
    let status: TripStatus
}
```

### TripStatus
```swift
enum TripStatus: String, Codable, CaseIterable {
    case planned = "Planned Trips"
    case completed = "Completed Trips"
    case ongoing = "Ongoing Trips"
}
```

### City
```swift
struct City: Identifiable, Codable {
    let id: UUID
    let name: String
    let country: String
    let imageURL: String
}
```

## 🛠 Development Tools

### Extensions & Helpers

**UIColor Extensions**
- Hex color initialization
- Brand colors (`.brand`, `.backgroundGray`)

**UIView Extensions**
- Auto Layout helpers (`anchor`, `fillSuperview`, `centerInSuperview`)
- Multiple subview addition
- Shimmer effects

**View Extensions**
- Custom corner radius
- Shimmer modifier

**UILabel Factory**
- Convenient label creation

**RemoteImageView**
- Async image loading
- Built-in caching
- Shimmer placeholder

## 🔐 Network Layer

### APIRequest Protocol
```swift
protocol APIRequest {
    associatedtype Response: Decodable
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
}
```

### HTTPClient Protocol
```swift
protocol HTTPClientProtocol {
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
}
```

## 📄 License

This project is part of the GoPaddi assessment.

## 👨‍💻 Author

**Oko-osi Korede Ibrahim**

## 🙏 Acknowledgments

- Design inspiration from modern travel apps
- Built with Apple's latest frameworks and best practices
- Following iOS Human Interface Guidelines
