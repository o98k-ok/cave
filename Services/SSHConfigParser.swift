import Foundation

struct SSHHostEntry: Identifiable, Hashable {
    let id: String          // Host alias (e.g. "happy")
    let hostName: String    // HostName (e.g. "8.140.192.71")
    let user: String?
    let port: Int?
    let identityFile: String?

    var displayName: String {
        if hostName == id {
            return id
        }
        return "\(id)  (\(hostName))"
    }
}

enum SSHConfigParser {
    static func parse() -> [SSHHostEntry] {
        let configPath = NSString("~/.ssh/config").expandingTildeInPath
        guard let content = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            return []
        }

        var entries: [SSHHostEntry] = []
        var currentHost: String?
        var hostName: String?
        var user: String?
        var port: Int?
        var identityFile: String?

        for rawLine in content.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            // Skip comments and empty lines
            if line.isEmpty || line.hasPrefix("#") { continue }

            let parts = line.split(separator: " ", maxSplits: 1).map { String($0) }
            guard parts.count == 2 else { continue }

            let key = parts[0].lowercased()
            let value = parts[1].trimmingCharacters(in: .init(charactersIn: "\""))

            if key == "host" {
                // Save previous entry
                if let host = currentHost {
                    entries.append(SSHHostEntry(
                        id: host,
                        hostName: hostName ?? host,
                        user: user,
                        port: port,
                        identityFile: identityFile
                    ))
                }

                // Skip wildcard hosts
                if value.contains("*") || value.contains("?") {
                    currentHost = nil
                    hostName = nil
                    user = nil
                    port = nil
                    identityFile = nil
                    continue
                }

                currentHost = value
                hostName = nil
                user = nil
                port = nil
                identityFile = nil
            } else if currentHost != nil {
                switch key {
                case "hostname": hostName = value
                case "user": user = value
                case "port": port = Int(value)
                case "identityfile": identityFile = value
                default: break
                }
            }
        }

        // Save last entry
        if let host = currentHost {
            entries.append(SSHHostEntry(
                id: host,
                hostName: hostName ?? host,
                user: user,
                port: port,
                identityFile: identityFile
            ))
        }

        return entries
    }
}
