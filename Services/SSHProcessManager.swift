import Foundation

final class SSHProcessManager {
    private var processes: [UUID: Process] = [:]
    private let queue = DispatchQueue(label: "ssh.process", qos: .utility)
    private let logURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("cave", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        logURL = dir.appendingPathComponent("ssh.log")
        // Clear old log on init
        try? "".write(to: logURL, atomically: true, encoding: .utf8)
        log("SSHProcessManager initialized")
    }

    private func log(_ message: String) {
        let ts = ISO8601DateFormatter().string(from: Date())
        let line = "[\(ts)] \(message)\n"
        if let data = line.data(using: .utf8),
           let fh = try? FileHandle(forWritingTo: logURL) {
            fh.seekToEndOfFile()
            fh.write(data)
            fh.closeFile()
        } else {
            try? line.write(to: logURL, atomically: false, encoding: .utf8)
        }
    }

    func start(
        config: TunnelConfig,
        onStatusChange: @escaping (ConnectionStatus, Int32?) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")

            let flag = config.isReverse ? "-R" : "-L"
            let mapping = config.isReverse
                ? "\(config.remotePort):\(config.remoteHost):\(config.localPort)"
                : "\(config.localPort):\(config.remoteHost):\(config.remotePort)"

            var args = [
                "-N",
                flag, mapping,
                "-p", "\(config.sshPort)",
                "-o", "ServerAliveInterval=30",
                "-o", "ServerAliveCountMax=3",
                "-o", "ExitOnForwardFailure=yes",
                "-o", "ConnectTimeout=15",
                "-o", "StrictHostKeyChecking=accept-new",
                "-o", "ControlMaster=no",
                "-o", "ControlPath=none"
            ]

            if let keyPath = config.sshKeyPath, !keyPath.isEmpty {
                args += ["-i", (keyPath as NSString).expandingTildeInPath]
            }

            args.append("\(config.sshUser)@\(config.sshHost)")
            process.arguments = args

            self.log("CMD: /usr/bin/ssh \(args.joined(separator: " "))")

            // Inherit user's shell environment (SSH_AUTH_SOCK, 1Password agent, etc.)
            var env = ProcessInfo.processInfo.environment
            self.log("SSH_AUTH_SOCK from env: \(env["SSH_AUTH_SOCK"] ?? "<nil>")")

            if env["SSH_AUTH_SOCK"] == nil {
                let onePasswordSocket = NSString("~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock").expandingTildeInPath
                let exists = FileManager.default.fileExists(atPath: onePasswordSocket)
                self.log("1Password socket \(onePasswordSocket) exists: \(exists)")
                if exists {
                    env["SSH_AUTH_SOCK"] = onePasswordSocket
                }
            }
            self.log("Final SSH_AUTH_SOCK: \(env["SSH_AUTH_SOCK"] ?? "<nil>")")
            self.log("HOME: \(env["HOME"] ?? "<nil>")")
            process.environment = env

            let errorPipe = Pipe()
            process.standardOutput = Pipe()
            process.standardError = errorPipe

            var errorOutput = ""
            let errorLock = NSLock()

            errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
                let data = handle.availableData
                if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                    self?.log("STDERR: \(str.trimmingCharacters(in: .whitespacesAndNewlines))")
                    errorLock.lock()
                    errorOutput += str
                    errorLock.unlock()
                }
            }

            process.terminationHandler = { [weak self] proc in
                let code = proc.terminationStatus
                self?.log("Process terminated with code: \(code)")

                self?.queue.async {
                    self?.processes.removeValue(forKey: config.id)
                }

                errorPipe.fileHandleForReading.readabilityHandler = nil

                if code != 0 && code != 15 {
                    errorLock.lock()
                    let reason = errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                    errorLock.unlock()
                    let msg = reason.isEmpty
                        ? String(format: L10n.t("error.processExitFmt"), code)
                        : reason
                    DispatchQueue.main.async { onStatusChange(.error(msg), nil) }
                }
            }

            do {
                try process.run()
                let pid = process.processIdentifier
                self.log("Process started with PID: \(pid)")

                self.queue.async { self.processes[config.id] = process }
                DispatchQueue.main.async { onStatusChange(.connecting, pid) }

                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) { [weak self] in
                    if config.isReverse {
                        // Reverse tunnel: can't verify remote port, check process is alive
                        self?.verifyProcess(
                            config: config, process: process, pid: pid,
                            getError: {
                                errorLock.lock()
                                defer { errorLock.unlock() }
                                return errorOutput
                            },
                            onStatusChange: onStatusChange
                        )
                    } else {
                        self?.verifyPort(
                            config: config, process: process, pid: pid,
                            attempt: 1,
                            getError: {
                                errorLock.lock()
                                defer { errorLock.unlock() }
                                return errorOutput
                            },
                            onStatusChange: onStatusChange
                        )
                    }
                }
            } catch {
                self.log("Failed to start process: \(error)")
                DispatchQueue.main.async {
                    onStatusChange(
                        .error(String(format: L10n.t("error.startFailedFmt"), error.localizedDescription)),
                        nil
                    )
                }
            }
        }
    }

    func stop(id: UUID) {
        queue.async { [weak self] in
            guard let process = self?.processes.removeValue(forKey: id) else { return }
            guard process.isRunning else { return }

            self?.log("Stopping process PID: \(process.processIdentifier)")
            process.terminate()

            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 3) {
                guard process.isRunning else { return }
                kill(process.processIdentifier, SIGKILL)
            }
        }
    }

    func stopAll() {
        queue.sync {
            for (_, process) in processes where process.isRunning {
                process.terminate()
                var wait = 0
                while process.isRunning && wait < 20 {
                    usleep(100_000)
                    wait += 1
                }
                if process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
            }
            processes.removeAll()
        }
    }

    func isRunning(id: UUID) -> Bool {
        queue.sync { processes[id]?.isRunning ?? false }
    }

    // MARK: - Private

    private func verifyProcess(
        config: TunnelConfig,
        process: Process,
        pid: Int32,
        getError: @escaping () -> String,
        onStatusChange: @escaping (ConnectionStatus, Int32?) -> Void
    ) {
        // For reverse tunnels: wait a moment, then check if process is still alive
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1) { [weak self] in
            if process.isRunning {
                self?.log("verifyProcess: reverse tunnel process \(pid) is running")
                DispatchQueue.main.async { onStatusChange(.connected, pid) }
            } else {
                let errMsg = getError().trimmingCharacters(in: .whitespacesAndNewlines)
                let msg = errMsg.isEmpty ? L10n.t("error.processDiedEarly") : errMsg
                self?.log("verifyProcess: process died - \(msg)")
                DispatchQueue.main.async { onStatusChange(.error(msg), nil) }
            }
        }
    }

    private func verifyPort(
        config: TunnelConfig,
        process: Process,
        pid: Int32,
        attempt: Int,
        getError: @escaping () -> String,
        onStatusChange: @escaping (ConnectionStatus, Int32?) -> Void
    ) {
        guard process.isRunning else {
            log("verifyPort: process no longer running at attempt \(attempt)")
            return
        }

        let listening = isPortListening(config.localPort)
        log("verifyPort attempt \(attempt): port \(config.localPort) listening = \(listening)")

        if listening {
            DispatchQueue.main.async { onStatusChange(.connected, pid) }
            return
        }

        if attempt < 10 {
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.verifyPort(
                    config: config, process: process, pid: pid,
                    attempt: attempt + 1, getError: getError, onStatusChange: onStatusChange
                )
            }
            return
        }

        stop(id: config.id)
        let errMsg = getError().trimmingCharacters(in: .whitespacesAndNewlines)
        let msg = errMsg.isEmpty ? L10n.t("error.connectionTimeout") : errMsg
        log("Connection timeout: \(msg)")
        DispatchQueue.main.async { onStatusChange(.error(msg), nil) }
    }

    private func isPortListening(_ port: Int) -> Bool {
        // Use direct socket connection instead of lsof (which can fail in app context)
        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else { return false }
        defer { close(sock) }

        // Set short timeout
        var timeout = timeval(tv_sec: 1, tv_usec: 0)
        setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        return result == 0
    }
}
