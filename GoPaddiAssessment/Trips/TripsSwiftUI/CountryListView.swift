import SwiftUI

struct CountryListView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: TripPlannerViewModel
    @State private var searchText: String = ""

    private var filtered: [City] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return viewModel.cities }
        return viewModel.cities.filter { c in
            c.city.localizedCaseInsensitiveContains(searchText) || c.countryCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filtered) { country in
            HStack(spacing: 12) {
                Text(country.flag)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(country.city).font(.body)
                    Text(country.countryCode)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
//                coordinator.path.append(AppRoute.countryDetail(code: country.code))
                viewModel.selectedCity = country.city
                coordinator.pop()
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Country")
        .onAppear {
            Task { await viewModel.getAllCities() }
        }
    }
}

#Preview("Country List") {
    NavigationStack { CountryListView() }
        .environmentObject(NavigationCoordinator())
}
