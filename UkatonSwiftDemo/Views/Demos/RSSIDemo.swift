import SwiftUI
import UkatonKit

struct RSSIDemo: View {
    var mission: UKMission
    @State private var rssi: Int = 0
    @State private var isReadingRSSI: Bool = false

    var body: some View {
        VStack {
            Button(action: {
                mission.toggleReadingRSSI()
            }) {
                if isReadingRSSI {
                    Text("stop reading rssi")
                }
                else {
                    Text("start reading rssi")
                }
            }
            .onReceive(mission.isReadingRSSISubject, perform: { isReadingRSSI = $0 })
            Text("rssi: \(rssi)")
                .onReceive(mission.rssiSubject, perform: { rssi = $0 })
        }
        .navigationTitle("RSSI")
    }
}

#Preview {
    NavigationStack {
        RSSIDemo(mission: .none)
    }
    .frame(maxWidth: 300, maxHeight: 300)
}
