//
//  TripPlannerViewModel.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

// MARK: - ViewModels/TripPlannerViewModel.swift

import Foundation
import SwiftUI
import Combine

@MainActor
final class TripPlannerViewModel: ObservableObject {

    var path: NavigationPath?
    // MARK: - Published State
    @Published var trips: [Trip] = []
    @Published var cities: [City] = []
    @Published var selectedStatus: TripStatus = .planned
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Form State
    @Published var selectedCity: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
    @Published var showCityPicker: Bool = false
    @Published var isCreatingTrip: Bool = false
    var tripName: String = ""

    var filteredTrips: [Trip] {
        trips.filter { $0.status == selectedStatus }
    }

    // MARK: - Dependencies
    private let repository: TripRepositoryProtocol

    init(repository: TripRepositoryProtocol? = nil) {
        self.repository = repository ?? TripRepository()
    }

    // MARK: - Intents
    func loadTrips() async {
        isLoading = true
        errorMessage = nil
        do {
            trips = try await repository.fetchTrips(status: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func getAllCities() async {
        isLoading = true
        errorMessage = nil
        do {
            cities = try await repository.fetchCities()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createTrip() async {
        guard !selectedCity.isEmpty else { return }
        isCreatingTrip = true
        do {
            let newTrip = try await repository.createTrip(
                destination: selectedCity,
                startDate: startDate,
                endDate: endDate,
                tripName: tripName
            )
            trips.insert(newTrip, at: 0)
            selectedCity = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isCreatingTrip = false
    }

    func selectStatus(_ status: TripStatus) {
        selectedStatus = status
    }
}
