import SwiftUI

struct CountryListView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: TripPlannerViewModel
    @State private var searchText: String = ""

    private var filtered: [Country] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return Country.allCountries }
        return Country.allCountries.filter { c in
            c.name.localizedCaseInsensitiveContains(searchText) || c.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filtered) { country in
            HStack(spacing: 12) {
                Text(country.flag)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(country.name).font(.body)
                    Text(country.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
//                coordinator.path.append(AppRoute.countryDetail(code: country.code))
                viewModel.selectedCity = country.name
                coordinator.pop()
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Select Country")
    }
}

#Preview("Country List") {
    NavigationStack { CountryListView() }
        .environmentObject(NavigationCoordinator())
}
