import SwiftUI

struct SelectCountryView: View {
    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Where are you traveling?")
                    .font(.largeTitle).bold()
                Text("Select a country to see available trips")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                nav.path.append(AppRoute.countryList)
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Select Country")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(20)
        .navigationTitle("Trips")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview("Select Country") {
    NavigationStack { SelectCountryView() }
        .environmentObject(NavigationCoordinator())
}
