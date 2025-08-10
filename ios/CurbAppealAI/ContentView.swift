import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Analyze")
                }
                .tag(1)
            
            ResultsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Results")
                }
                .tag(2)
        }
        .accentColor(.primary)
    }
}