import SwiftUI

struct CountryDetailView: View {
    @EnvironmentObject private var nav: NavigationCoordinator
    let city: City

//    private var country: City? = nil

    init(city: City) {
        self.city = city
    }

    var body: some View {
        VStack(spacing: 16) {
//            if let country = country {
                Text(city.flag)
                    .font(.system(size: 96))
                Text(city.city)
                    .font(.title).bold()
                Text(city.countryCode)
                    .foregroundStyle(.secondary)
//            } else {
//                Text("Unknown Country")
//            }

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
    NavigationStack { CountryDetailView(city: City(name: "Afghanistan", code: "AF", flag: "🇦🇫")) }
        .environmentObject(NavigationCoordinator())
}
