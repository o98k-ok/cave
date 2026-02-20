import Foundation

final class TunnelStore {
    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("cave", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("tunnels.json")
    }

    func load() -> [TunnelConfig] {
        guard let data = try? Data(contentsOf: fileURL),
              let tunnels = try? JSONDecoder().decode([TunnelConfig].self, from: data) else {
            return []
        }
        return tunnels
    }

    func save(_ tunnels: [TunnelConfig]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(tunnels) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
