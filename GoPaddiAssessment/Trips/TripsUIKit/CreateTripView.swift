//
//  CreateTripView.swift
//  GoPaddiAssessment
//
//  Created by Oko-osi Korede Ibrahim on 27/02/2026.
//

import SwiftUI
import Combine

/// Travel style options for the trip
enum TravelStyle: String, CaseIterable, Identifiable {
    case solo = "Solo"
    case couple = "Couple"
    case family = "Family"
    case group = "Group"
    
    var id: String { rawValue }
}

/// Main view for creating a new trip
struct CreateTripView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var coordinatorViewModel: TripPlannerViewModel
    @StateObject private var viewModel = CreateTripViewModel()
    
    /// Optional callback when trip creation is initiated
    var onCreateTrip: ((String, TravelStyle, String) -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                headerSection
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Trip Name
                    tripNameSection
                    
                    // Travel Style
                    travelStyleSection
                    
                    // Trip Description
                    tripDescriptionSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) {
            nextButton
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                )
        }
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            hideKeyboard()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "gift.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Create a Trip")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Let's Go! Build Your Next Adventure")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGray6).opacity(0.3))
    }
    
    // MARK: - Trip Name Section
    
    private var tripNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trip Name")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            TextField("Enter the trip name", text: $viewModel.tripName)
                .textFieldStyle(CustomTextFieldStyle())
                .accessibilityLabel("Trip Name")
                .accessibilityHint("Enter a name for your trip")
        }
    }
    
    // MARK: - Travel Style Section
    
    private var travelStyleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Travel Style")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                // Dropdown button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.isTravelStyleExpanded.toggle()
                    }
                    // Haptic feedback
                    #if os(iOS)
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    #endif
                } label: {
                    HStack {
                        Text(viewModel.selectedTravelStyle?.rawValue ?? "Select your travel style")
                            .foregroundColor(viewModel.selectedTravelStyle == nil ? .secondary : .primary)
                            .font(.system(size: 15))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(viewModel.isTravelStyleExpanded ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.selectedTravelStyle != nil ? Color.blue : Color(.systemGray4), lineWidth: viewModel.selectedTravelStyle != nil ? 2 : 1)
                    )
                }
                .accessibilityLabel("Travel Style")
                .accessibilityHint(viewModel.selectedTravelStyle == nil ? "Select your preferred travel style" : "Currently selected: \(viewModel.selectedTravelStyle!.rawValue)")
                
                // Dropdown options
                if viewModel.isTravelStyleExpanded {
                    VStack(spacing: 0) {
                        ForEach(TravelStyle.allCases) { style in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedTravelStyle = style
                                    viewModel.isTravelStyleExpanded = false
                                }
                                // Haptic feedback
                                #if os(iOS)
                                let selectionFeedback = UISelectionFeedbackGenerator()
                                selectionFeedback.selectionChanged()
                                #endif
                            } label: {
                                HStack {
                                    Text(style.rawValue)
                                        .foregroundColor(.primary)
                                        .font(.system(size: 15))
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedTravelStyle == style {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(viewModel.selectedTravelStyle == style ? Color.blue : Color(.systemBackground))
                                .foregroundColor(viewModel.selectedTravelStyle == style ? .white : .primary)
                            }
                            .accessibilityLabel(style.rawValue)
                            .accessibilityAddTraits(viewModel.selectedTravelStyle == style ? [.isSelected] : [])
                            
                            if style != TravelStyle.allCases.last {
                                Divider()
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
    
    // MARK: - Trip Description Section
    
    private var tripDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trip Description")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                if viewModel.tripDescription.isEmpty {
                    Text("Tell us more about the trip")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
                
                TextEditor(text: $viewModel.tripDescription)
                    .font(.system(size: 15))
                    .frame(minHeight: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Next Button
    
    private var nextButton: some View {
        Button {
            viewModel.handleNext { tripName, travelStyle, description in
                // Call completion handler if provided
                onCreateTrip?(tripName, travelStyle, description)
                let trip = Trip(id: UUID(), title: tripName, destination: description, startDate: coordinatorViewModel.startDate, endDate: coordinatorViewModel.endDate, imageURL: "", status: .planned)
                coordinator.dismissSheet()
                coordinator.push(.tripDetails(trip: trip))
                // Haptic feedback for success
                #if os(iOS)
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                #endif
                
                // Optionally dismiss or navigate to next screen
                // dismiss()
            }
        } label: {
            HStack {
                Spacer()
                Text("Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.isFormValid ? .white : .secondary)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(viewModel.isFormValid ? Color.blue : Color(.systemGray5))
            .cornerRadius(10)
        }
        .disabled(!viewModel.isFormValid)
        .accessibilityLabel("Next")
        .accessibilityHint(viewModel.isFormValid ? "Proceed to next step" : "Complete required fields to continue")
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 15))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

// MARK: - View Model

@MainActor
final class CreateTripViewModel: ObservableObject {
    @Published var tripName: String = ""
    @Published var selectedTravelStyle: TravelStyle?
    @Published var tripDescription: String = ""
    @Published var isTravelStyleExpanded: Bool = false
    
    var isFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedTravelStyle != nil
    }
    
    func handleNext(completion: @escaping (String, TravelStyle, String) -> Void) {
        guard isFormValid, let travelStyle = selectedTravelStyle else { return }
        
        let trimmedName = tripName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = tripDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Log for debugging
        print("Trip Name: \(trimmedName)")
        print("Travel Style: \(travelStyle.rawValue)")
        print("Description: \(trimmedDescription)")
        
        // Call completion handler
        completion(trimmedName, travelStyle, trimmedDescription)
    }
}

// MARK: - Helper Extensions

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - Preview

#Preview {
    CreateTripView()
}
