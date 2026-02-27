//
//  Models.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 26/02/2026.
//

// MARK: - Network/Models.swift

import Foundation

// MARK: - Trip Model
struct Trip: Identifiable, Codable {
    let id: UUID
    let title: String
    let destination: String
    let startDate: Date
    let endDate: Date
    let imageURL: String
    let status: TripStatus

    var durationDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: startDate)
    }
}

enum TripStatus: String, Codable, CaseIterable {
    case planned = "Planned Trips"
    case completed = "Completed Trips"
    case ongoing = "Ongoing Trips"
}

// MARK: - City Model
struct City: Identifiable, Codable {
    let id: UUID
    let name: String
    let country: String
    let imageURL: String
}

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError(let e): return "Decoding failed: \(e.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        case .unknown(let e): return e.localizedDescription
        }
    }
}
