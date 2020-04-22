import SwiftUI
import os.log

import WebPImage

private extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")
}

struct CellContentView: View {
    private let name: String
    @State private var isPlaying: Bool = true

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        VStack(alignment: .center) {
            WebP(name, isPlaying: $isPlaying) { Text("Image is loading...") }
                .onPlay { os_log("%{PUBLIC}@(1) > play", log: OSLog.viewCycle, type: .info, self.name) }
                .onPause { os_log("%{PUBLIC}@(1) > pause", log: OSLog.viewCycle, type: .info, self.name) }
                .onRender { (index, fromCache) in os_log("%{PUBLIC}@(1) > render %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, fromCache ? "from cache" : "from context") }
                .onComplete { loopMode in os_log("%{PUBLIC}@(1) > complete %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, loopMode.description) }
                .playBackSpeedRate(0.5)
                .resizable()
                .antialiased(true)
                .scaledToFit()

            WebP(try! WebPImage(named: name), isPlaying: $isPlaying) { EmptyView() }
                .onPlay { os_log("%{PUBLIC}@(2) > play", log: OSLog.viewCycle, type: .info, self.name) }
                .onPause { os_log("%{PUBLIC}@(2) > pause", log: OSLog.viewCycle, type: .info, self.name) }
                .onRender { (index, fromCache) in os_log("%{PUBLIC}@(2) > render %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, fromCache ? "from cache" : "from context") }
                .onComplete { loopMode in os_log("%{PUBLIC}@(2) > complete %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, loopMode.description) }
                .loopMode(.infinite)
                .playBackSpeedRate(4)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .renderingMode(.template)
                .foregroundColor(.blue)
                .background(Color.red.opacity(0.1))
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipped(antialiased: true)

            WebP(name, isPlaying: $isPlaying) { EmptyView() }
                .onPlay { os_log("%{PUBLIC}@(3) > play", log: OSLog.viewCycle, type: .info, self.name) }
                .onPause { os_log("%{PUBLIC}@(3) > pause", log: OSLog.viewCycle, type: .info, self.name) }
                .onRender { (index, fromCache) in os_log("%{PUBLIC}@(3) > render %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, fromCache ? "from cache" : "from context") }
                .onComplete { loopMode in os_log("%{PUBLIC}@(3) > complete %{PUBLIC}@", log: OSLog.viewCycle, type: .info, self.name, loopMode.description) }
                .loopMode(.infinite)
                .playBackSpeedRate(4)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipped(antialiased: true)
        }
        .onAppear(perform: { os_log("%{PUBLIC}@ > appear", log: OSLog.viewCycle, type: .info, self.name); self.isPlaying = true })
        .onDisappear(perform: { os_log("%{PUBLIC}@ > disappear", log: OSLog.viewCycle, type: .info, self.name); self.isPlaying = false })
    }
}

struct ContentView: View {
    var body: some View {

        NavigationView {
            List {
                ForEach(WebPImageAsset.allCases, id: \.self) { webp in
                    NavigationLink(destination: webp.name.map { name in
                        CellContentView(name)
                    }) {
                        Text(webp.name ?? "No image")
                    }
                }
            }
            .navigationBarTitle("WebP SwiftUI")
            .listStyle(GroupedListStyle())
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
