import Foundation

enum ConnectionStatus: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    var isActive: Bool {
        switch self {
        case .connected, .connecting: return true
        default: return false
        }
    }
}

struct TunnelState {
    var status: ConnectionStatus = .disconnected
    var processId: Int32?
    var connectedAt: Date?

    var errorMessage: String? {
        if case .error(let msg) = status { return msg }
        return nil
    }
}
