# TripPlanner – SwiftUI

A clean SwiftUI implementation of the Trip Planner design, with a protocol-based network layer and mock data.

## Project Structure

```
TripPlanner/
├── TripPlannerApp.swift          # App entry point
│
├── Network/
│   ├── Models.swift              # Trip, City, NetworkError models
│   ├── HTTPClient.swift          # Protocol-based HTTP client (URLSession)
│   └── TripRepository.swift      # API requests + Live & Mock repositories
│
├── ViewModels/
│   └── TripPlannerViewModel.swift # @MainActor ObservableObject, all UI state
│
├── Views/
│   ├── ContentView.swift         # Root view, composes sections
│   ├── HeroSection.swift         # Header + booking form card
│   └── TripsSection.swift        # Trips list, status filter, cards, skeletons
│
└── Helpers/
    └── Extensions.swift          # Color(hex:), cornerRadius corners, shimmer
```

## Architecture

**MVVM + Repository Pattern**

- `TripPlannerViewModel` — single source of truth for the screen, uses `async/await`
- `TripRepositoryProtocol` — abstracts data fetching; swap `MockTripRepository` ↔ `TripRepository` at the `init` call site
- `HTTPClientProtocol` — abstracts URLSession; easily injectable for testing

## Switching to Live Network

In `TripPlannerViewModel.swift`, change:
```swift
// Mock (default)
init(repository: TripRepositoryProtocol = MockTripRepository.shared)

// Live
init(repository: TripRepositoryProtocol = TripRepository())
```

Update the `baseURL` in `HTTPClient.init` to your real API endpoint.

## Features

- Booking form with city picker sheet, date pickers, and create trip action
- Animated trip cards with `AsyncImage` loading
- Shimmer skeleton loading state
- Status filter (Planned / Ongoing / Completed) via dropdown Menu
- Spring press animation on cards
- Error + empty state handling
- All colors via `Color(hex:)` extension
