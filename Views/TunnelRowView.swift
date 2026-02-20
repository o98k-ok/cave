import SwiftUI

struct TunnelRowView: View {
    let config: TunnelConfig
    let state: TunnelState
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @State private var showDeleteConfirm = false
    @AppStorage(L10n.languageKey) private var languageCode = AppLanguage.defaultLanguage.rawValue

    private var language: AppLanguage { AppLanguage.from(code: languageCode) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Row 1: Name + Actions + Status
            topBar

            // Route chain (clickable nodes)
            routeChain

            // Error message
            if let msg = state.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                    Text(msg)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                .foregroundStyle(Theme.red)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.red.opacity(0.08))
                )
            }

            // Runtime info (PID + uptime)
            if state.status == .connected {
                runtimeInfo
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isHovered ? borderColor.opacity(0.5) : Theme.cardBorder, lineWidth: 1)
        )
        .onHover { isHovered = $0 }
        .alert(L10n.t("action.confirmDelete", language: language), isPresented: $showDeleteConfirm) {
            Button(L10n.t("action.cancel", language: language), role: .cancel) {}
            Button(L10n.t("action.delete", language: language), role: .destructive, action: onDelete)
        } message: {
            Text(String(format: L10n.t("message.deleteConfirmFmt", language: language), config.name))
        }
    }

    // MARK: - Top Bar: Name + Actions + Status

    private var topBar: some View {
        HStack(spacing: 8) {
            Text(config.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(Color.white.opacity(0.06))
                )
                .overlay(
                    Capsule().stroke(Theme.cardBorder, lineWidth: 1)
                )
                .frame(height: 28)

            // Status badge
            StatusBadge(status: state.status)

            // Toggle button
            PillButton(
                title: state.status.isActive
                    ? L10n.t("action.stop", language: language)
                    : L10n.t("action.start", language: language),
                icon: state.status.isActive ? "stop.fill" : "play.fill",
                color: state.status.isActive ? Theme.orange : Theme.green
            ) { onToggle() }
            .opacity(state.status == .connecting ? 0.5 : 1)
            .allowsHitTesting(state.status != .connecting)

            if state.status == .connecting {
                ProgressView()
                    .controlSize(.small)
                    .tint(Theme.orange)
            }

            Spacer()

            // Edit
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }
            .buttonStyle(.borderless)
            .disabled(state.status.isActive)
            .opacity(state.status.isActive ? 0.3 : 1)

            // Delete
            Button(action: { showDeleteConfirm = true }) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.red.opacity(0.8))
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(Theme.red.opacity(0.08)))
            }
            .buttonStyle(.borderless)
            .disabled(state.status.isActive)
            .opacity(state.status.isActive ? 0.3 : 1)
        }
    }

    // MARK: - Route Chain

    private var routeChain: some View {
        HStack(spacing: 0) {
            CopyableRouteNode(
                icon: "desktopcomputer",
                label: "\(config.localPort)",
                detail: nil,
                copyText: "localhost:\(config.localPort)",
                active: state.status.isActive
            )
            .frame(width: 86, alignment: .leading)

            routeArrow(active: state.status.isActive, reverse: config.isReverse)
                .frame(maxWidth: .infinity)

            CopyableRouteNode(
                icon: "server.rack",
                label: truncate(config.sshHost, max: 14),
                detail: nil,
                copyText: config.sshHost,
                active: state.status.isActive
            )
            .frame(width: 120)

            routeArrow(active: state.status == .connected, reverse: config.isReverse)
                .frame(maxWidth: .infinity)

            CopyableRouteNode(
                icon: "globe",
                label: "\(config.remotePort)",
                detail: nil,
                copyText: "\(config.remoteHost):\(config.remotePort)",
                active: state.status == .connected
            )
            .frame(width: 86, alignment: .trailing)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.03))
        )
    }

    private func routeArrow(active: Bool, reverse: Bool) -> some View {
        GeometryReader { geo in
            let step: CGFloat = 10
            let count = max(5, Int(geo.size.width / step) - 1)
            let color = active
                ? (reverse ? Theme.purple.opacity(0.7) : Theme.green.opacity(0.7))
                : Theme.textTertiary

            ZStack {
                HStack(spacing: 0) {
                    ForEach(0..<count, id: \.self) { idx in
                        Circle()
                            .fill(color)
                            .frame(width: 3, height: 3)
                        if idx < count - 1 {
                            Spacer(minLength: 0)
                        }
                    }
                }

                Image(systemName: reverse ? "chevron.left" : "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 3)
                    .background(Color.black.opacity(0.001))
            }
        }
        .frame(height: 12)
    }

    // MARK: - Runtime Info

    private var runtimeInfo: some View {
        HStack(spacing: 14) {
            if let pid = state.processId {
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.system(size: 9))
                    Text("PID \(pid)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                }
                .foregroundStyle(Theme.green)
            }
            if let connectedAt = state.connectedAt {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    UptimeLabel(since: connectedAt)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                }
                .foregroundStyle(Theme.green)
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private var borderColor: Color {
        switch state.status {
        case .error: return Theme.red
        case .connected: return Theme.green
        case .connecting: return Theme.orange
        default: return Theme.cardBorder
        }
    }

    private func truncate(_ str: String, max: Int) -> String {
        str.count > max ? String(str.prefix(max - 1)) + "…" : str
    }
}

// MARK: - Copyable Route Node

struct CopyableRouteNode: View {
    let icon: String
    let label: String
    let detail: String?
    let copyText: String
    let active: Bool

    @State private var copied = false
    @AppStorage(L10n.languageKey) private var languageCode = AppLanguage.defaultLanguage.rawValue

    private var language: AppLanguage { AppLanguage.from(code: languageCode) }

    var body: some View {
        Button(action: copyToClipboard) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(copied ? Theme.green.opacity(0.25)
                              : active ? Theme.green.opacity(0.12) : Color.white.opacity(0.05))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle().stroke(
                                copied ? Theme.green.opacity(0.6)
                                : active ? Theme.green.opacity(0.4) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                        )

                    Image(systemName: copied ? "checkmark" : icon)
                        .font(.system(size: 11))
                        .foregroundStyle(copied ? Theme.green : active ? Theme.green : Theme.textTertiary)
                }

                Text(copied ? L10n.t("message.copied", language: language) : label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(copied ? Theme.green : Theme.textSecondary)
                    .lineLimit(1)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(active ? Theme.green : Theme.textTertiary)
                        .lineLimit(1)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .help(String(format: L10n.t("message.clickToCopyFmt", language: language), copyText))
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(copyText, forType: .string)
        withAnimation(.easeInOut(duration: 0.2)) { copied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.2)) { copied = false }
        }
    }
}

// MARK: - Uptime Label

struct UptimeLabel: View {
    let since: Date
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(formatted)
            .onReceive(timer) { now = $0 }
    }

    private var formatted: String {
        let elapsed = max(0, Int(now.timeIntervalSince(since)))
        let h = elapsed / 3600
        let m = elapsed % 3600 / 60
        let s = elapsed % 60
        return h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}
