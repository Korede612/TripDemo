import SwiftUI

struct CountryDetailView: View {
    @EnvironmentObject private var nav: NavigationCoordinator
    let countryCode: String

    private var country: Country? {
        Country.allCountries.first { $0.code == countryCode }
    }

    var body: some View {
        VStack(spacing: 16) {
            if let country = country {
                Text(country.flag)
                    .font(.system(size: 96))
                Text(country.name)
                    .font(.title).bold()
                Text(country.code)
                    .foregroundStyle(.secondary)
            } else {
                Text("Unknown Country")
            }

            Spacer()

            Button("Done") {
                nav.path.removeLast(nav.path.count)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Country")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Country Detail") {
    NavigationStack { CountryDetailView(countryCode: "NG") }
        .environmentObject(NavigationCoordinator())
}
