import Foundation
import AppKit
import Darwin

struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let isError: Bool
}

final class TunnelViewModel: ObservableObject {
    @Published var tunnels: [TunnelConfig] = []
    @Published var states: [UUID: TunnelState] = [:]
    @Published var alert: AlertInfo?
    @Published var editingTunnel: TunnelConfig?
    @Published var showingForm = false
    @Published var showingSettings = false

    private let store = TunnelStore()
    private let processManager = SSHProcessManager()
    private var monitorTimer: Timer?

    init() {
        tunnels = store.load()
        startMonitor()
        setupTerminationHandler()
    }

    // MARK: - CRUD

    func addTunnel(_ config: TunnelConfig, password: String?) {
        tunnels.append(config)
        if config.usePassword, let password, !password.isEmpty {
            KeychainManager.shared.save(password, for: config.id)
        }
        save()
    }

    func updateTunnel(_ config: TunnelConfig, password: String?) {
        guard let idx = tunnels.firstIndex(where: { $0.id == config.id }) else { return }
        tunnels[idx] = config
        if config.usePassword, let password, !password.isEmpty {
            KeychainManager.shared.save(password, for: config.id)
        }
        save()
    }

    func deleteTunnel(_ config: TunnelConfig) {
        processManager.stop(id: config.id)
        KeychainManager.shared.delete(for: config.id)
        tunnels.removeAll { $0.id == config.id }
        states.removeValue(forKey: config.id)
        save()
    }

    // MARK: - Connection

    func toggleTunnel(_ config: TunnelConfig) {
        let state = states[config.id] ?? TunnelState()
        if state.status.isActive {
            stopTunnel(config)
        } else {
            startTunnel(config)
        }
    }

    func startTunnel(_ config: TunnelConfig) {
        states[config.id] = TunnelState(status: .connecting)

        processManager.start(config: config) { [weak self] status, pid in
            guard let self else { return }
            var state = TunnelState(status: status, processId: pid)

            switch status {
            case .connected:
                state.connectedAt = Date()
                self.alert = AlertInfo(
                    title: L10n.t("alert.connectedTitle"),
                    message: String(
                        format: L10n.t("alert.connectedMessageFmt"),
                        config.name,
                        config.localPort,
                        config.remoteHost,
                        config.remotePort
                    ),
                    isError: false
                )
            case .error(let msg):
                self.alert = AlertInfo(
                    title: L10n.t("alert.failedTitle"),
                    message: "\(config.name)\n\(msg)",
                    isError: true
                )
            default:
                break
            }

            self.states[config.id] = state
        }
    }

    func stopTunnel(_ config: TunnelConfig) {
        processManager.stop(id: config.id)
        states[config.id] = TunnelState(status: .disconnected)
    }

    func state(for id: UUID) -> TunnelState {
        states[id] ?? TunnelState()
    }

    // MARK: - Form

    func showAddForm() {
        editingTunnel = nil
        showingForm = true
    }

    func showEditForm(_ config: TunnelConfig) {
        editingTunnel = config
        showingForm = true
    }

    func showSettings() {
        showingSettings = true
    }

    func shutdownAndQuit() {
        processManager.stopAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApplication.shared.terminate(nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            NSRunningApplication.current.forceTerminate()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            exit(0)
        }
    }

    // MARK: - Private

    private func save() {
        store.save(tunnels)
    }

    private func startMonitor() {
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.checkProcesses()
        }
    }

    private func checkProcesses() {
        for tunnel in tunnels {
            guard let state = states[tunnel.id], state.status == .connected else { continue }
            if !processManager.isRunning(id: tunnel.id) {
                states[tunnel.id] = TunnelState(status: .error(L10n.t("error.processUnexpectedExit")))
                alert = AlertInfo(
                    title: L10n.t("alert.disconnectedTitle"),
                    message: String(format: L10n.t("alert.processEndedFmt"), tunnel.name),
                    isError: true
                )
            }
        }
    }

    private func setupTerminationHandler() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.processManager.stopAll()
        }
    }
}
