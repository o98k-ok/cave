import Foundation

struct TunnelConfig: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var localPort: Int
    var remoteHost: String
    var remotePort: Int
    var sshHost: String
    var sshUser: String
    var sshPort: Int
    var sshKeyPath: String?
    var usePassword: Bool
    var isReverse: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        localPort: Int,
        remoteHost: String,
        remotePort: Int,
        sshHost: String,
        sshUser: String,
        sshPort: Int = 22,
        sshKeyPath: String? = nil,
        usePassword: Bool = false,
        isReverse: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.sshHost = sshHost
        self.sshUser = sshUser
        self.sshPort = sshPort
        self.sshKeyPath = sshKeyPath
        self.usePassword = usePassword
        self.isReverse = isReverse
        self.createdAt = createdAt
    }

    // Backward compatible decoding: isReverse defaults to false if missing
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        localPort = try c.decode(Int.self, forKey: .localPort)
        remoteHost = try c.decode(String.self, forKey: .remoteHost)
        remotePort = try c.decode(Int.self, forKey: .remotePort)
        sshHost = try c.decode(String.self, forKey: .sshHost)
        sshUser = try c.decode(String.self, forKey: .sshUser)
        sshPort = try c.decode(Int.self, forKey: .sshPort)
        sshKeyPath = try c.decodeIfPresent(String.self, forKey: .sshKeyPath)
        usePassword = try c.decode(Bool.self, forKey: .usePassword)
        isReverse = try c.decodeIfPresent(Bool.self, forKey: .isReverse) ?? false
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    var sshCommand: String {
        let flag = isReverse ? "-R" : "-L"
        let mapping = isReverse
            ? "\(remotePort):\(remoteHost):\(localPort)"
            : "\(localPort):\(remoteHost):\(remotePort)"
        var cmd = "ssh -N \(flag) \(mapping)"
        if let keyPath = sshKeyPath, !keyPath.isEmpty {
            cmd += " -i \(keyPath)"
        }
        cmd += " -p \(sshPort) \(sshUser)@\(sshHost)"
        return cmd
    }
}
