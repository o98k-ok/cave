import SwiftUI

struct TunnelFormView: View {
    @ObservedObject var viewModel: TunnelViewModel
    let editingTunnel: TunnelConfig?
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var localPort = ""
    @State private var remoteHost = "localhost"
    @State private var remotePort = ""
    @State private var sshHost = ""
    @State private var sshUser = ""
    @State private var sshPort = "22"
    @State private var sshKeyPath = ""
    @State private var usePassword = false
    @State private var password = ""
    @State private var isReverse = false

    @State private var sshHosts: [SSHHostEntry] = []
    @State private var selectedHostId: String?  // nil = manual input
    @AppStorage(L10n.languageKey) private var languageCode = AppLanguage.defaultLanguage.rawValue

    private var isEditing: Bool { editingTunnel != nil }
    private var language: AppLanguage { AppLanguage.from(code: languageCode) }

    init(viewModel: TunnelViewModel, editingTunnel: TunnelConfig?) {
        self.viewModel = viewModel
        self.editingTunnel = editingTunnel
        if let t = editingTunnel {
            _name = State(initialValue: t.name)
            _localPort = State(initialValue: String(t.localPort))
            _remoteHost = State(initialValue: t.remoteHost)
            _remotePort = State(initialValue: String(t.remotePort))
            _sshHost = State(initialValue: t.sshHost)
            _sshUser = State(initialValue: t.sshUser)
            _sshPort = State(initialValue: String(t.sshPort))
            _sshKeyPath = State(initialValue: t.sshKeyPath ?? "")
            _usePassword = State(initialValue: t.usePassword)
            _isReverse = State(initialValue: t.isReverse)
        }
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 0) {
                formHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        formSection(L10n.t("form.section.basic", language: language)) {
                            themedField(
                                L10n.t("form.name", language: language),
                                text: $name,
                                placeholder: L10n.t("form.name.placeholder", language: language),
                                icon: "tag"
                            )
                        }

                        formSection(L10n.t("form.section.direction", language: language)) {
                            directionPicker
                        }

                        formSection(L10n.t("form.section.mapping", language: language)) {
                            HStack(spacing: 10) {
                                themedField(
                                    isReverse
                                        ? L10n.t("form.localPortService", language: language)
                                        : L10n.t("form.localPort", language: language),
                                    text: $localPort,
                                    placeholder: isReverse ? "3000" : "3306",
                                    icon: "arrow.up.circle"
                                )
                                Text(isReverse ? "←" : "→")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(isReverse ? Theme.purple : Theme.green)
                                themedField(
                                    isReverse
                                        ? L10n.t("form.remotePortExpose", language: language)
                                        : L10n.t("form.remotePort", language: language),
                                    text: $remotePort,
                                    placeholder: isReverse ? "8080" : "3306",
                                    icon: "arrow.down.circle"
                                )
                            }
                            themedField(
                                isReverse
                                    ? L10n.t("form.localBind", language: language)
                                    : L10n.t("form.remoteHost", language: language),
                                text: $remoteHost,
                                placeholder: "localhost",
                                icon: "globe"
                            )
                        }

                        formSection(L10n.t("form.section.ssh", language: language)) {
                            sshHostPicker

                            if selectedHostId == nil {
                                // Manual input mode
                                themedField(L10n.t("form.host", language: language), text: $sshHost, placeholder: "example.com", icon: "server.rack")
                                HStack(spacing: 10) {
                                    themedField(L10n.t("form.user", language: language), text: $sshUser, placeholder: "root", icon: "person")
                                    themedField(L10n.t("form.port", language: language), text: $sshPort, placeholder: "22", icon: "number")
                                        .frame(width: 90)
                                }
                            }
                        }

                        formSection(L10n.t("form.section.auth", language: language)) {
                            authPicker
                            if usePassword {
                                themedSecureField(
                                    L10n.t("form.password", language: language),
                                    text: $password,
                                    placeholder: L10n.t("form.password.placeholder", language: language),
                                    icon: "lock"
                                )
                            } else if selectedHostId == nil {
                                themedField(
                                    L10n.t("form.keyPath", language: language),
                                    text: $sshKeyPath,
                                    placeholder: "~/.ssh/id_rsa",
                                    icon: "key"
                                )
                            }
                        }

                        saveButton
                    }
                    .padding(16)
                }
            }
        }
        .frame(width: 420, height: 520)
        .onAppear { loadSSHConfig() }
    }

    // MARK: - SSH Host Picker

    private var sshHostPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if sshHosts.isEmpty {
                // No ssh config entries, just show manual fields
                EmptyView()
            } else {
                // Grid of host options
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(sshHosts) { host in
                        hostCard(host)
                    }

                    // Manual input option
                    Button(action: { selectManualInput() }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(selectedHostId == nil
                                          ? Theme.purple.opacity(0.15)
                                          : Color.white.opacity(0.05))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle().stroke(
                                            selectedHostId == nil
                                            ? Theme.purple.opacity(0.5)
                                            : Color.white.opacity(0.1),
                                            lineWidth: 1
                                        )
                                    )
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 12))
                                    .foregroundStyle(selectedHostId == nil ? Theme.purple : Theme.textTertiary)
                            }

                            Text(L10n.t("form.manualInput", language: language))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(selectedHostId == nil ? Theme.purple : Theme.textSecondary)
                                .lineLimit(1)

                            Text(" ")
                                .font(.system(size: 9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedHostId == nil
                                      ? Theme.purple.opacity(0.08)
                                      : Color.white.opacity(0.02))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedHostId == nil
                                        ? Theme.purple.opacity(0.3)
                                        : Theme.inputBorder,
                                        lineWidth: 1)
                        )
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private func hostCard(_ host: SSHHostEntry) -> some View {
        let isSelected = selectedHostId == host.id

        return Button(action: { selectHost(host) }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? Theme.green.opacity(0.15)
                              : Color.white.opacity(0.05))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle().stroke(
                                isSelected
                                ? Theme.green.opacity(0.5)
                                : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                        )
                    Image(systemName: isSelected ? "checkmark" : "server.rack")
                        .font(.system(size: 12))
                        .foregroundStyle(isSelected ? Theme.green : Theme.textTertiary)
                }

                Text(host.id)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isSelected ? Theme.green : Theme.textPrimary)
                    .lineLimit(1)

                Text(host.hostName)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected
                          ? Theme.green.opacity(0.06)
                          : Color.white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected
                            ? Theme.green.opacity(0.3)
                            : Theme.inputBorder,
                            lineWidth: 1)
            )
        }
        .buttonStyle(.borderless)
    }

    // MARK: - Actions

    private func loadSSHConfig() {
        sshHosts = SSHConfigParser.parse()

        // If editing, try to match existing config to an ssh host
        if let tunnel = editingTunnel {
            if let match = sshHosts.first(where: {
                $0.hostName == tunnel.sshHost || $0.id == tunnel.sshHost
            }) {
                selectedHostId = match.id
            }
        }
    }

    private func selectHost(_ host: SSHHostEntry) {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedHostId = host.id
        }
        sshHost = host.hostName
        sshUser = host.user ?? "root"
        sshPort = String(host.port ?? 22)
        if let keyPath = host.identityFile {
            sshKeyPath = keyPath
            usePassword = false
        }
        // Auto-fill name if empty
        if name.isEmpty {
            name = host.id
        }
    }

    private func selectManualInput() {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedHostId = nil
        }
        sshHost = ""
        sshUser = ""
        sshPort = "22"
    }

    // MARK: - Components

    private var formHeader: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Theme.purple, Theme.pink],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Image(systemName: isEditing ? "pencil" : "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text(isEditing
                    ? L10n.t("form.editTunnel", language: language)
                    : L10n.t("form.createTunnel", language: language))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.cardBg.opacity(0.6))
        .overlay(alignment: .bottom) {
            Divider().background(Theme.cardBorder)
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.5)
            content()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cardBg))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.cardBorder, lineWidth: 1))
    }

    private func themedField(_ title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(Theme.purple.opacity(0.7))
                .frame(width: 16)
            TextField(title, text: text, prompt: Text(placeholder).foregroundColor(Theme.textTertiary))
                .font(.system(size: 13))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.inputBg))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.inputBorder, lineWidth: 1))
    }

    private func themedSecureField(_ title: String, text: Binding<String>, placeholder: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(Theme.purple.opacity(0.7))
                .frame(width: 16)
            SecureField(title, text: text, prompt: Text(placeholder).foregroundColor(Theme.textTertiary))
                .font(.system(size: 13))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.inputBg))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.inputBorder, lineWidth: 1))
    }

    private var directionPicker: some View {
        HStack(spacing: 8) {
            directionOption(
                title: L10n.t("form.forward.title", language: language),
                subtitle: L10n.t("form.forward.desc", language: language),
                icon: "arrow.right",
                selected: !isReverse
            ) { withAnimation(.easeInOut(duration: 0.15)) { isReverse = false } }

            directionOption(
                title: L10n.t("form.reverse.title", language: language),
                subtitle: L10n.t("form.reverse.desc", language: language),
                icon: "arrow.left",
                selected: isReverse
            ) { withAnimation(.easeInOut(duration: 0.15)) { isReverse = true } }
        }
    }

    private func directionOption(title: String, subtitle: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        let color = selected ? (isReverse ? Theme.purple : Theme.green) : Theme.textSecondary
        return Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(selected ? color.opacity(0.7) : Theme.textTertiary)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? color.opacity(0.10) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? color.opacity(0.3) : Theme.inputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.borderless)
    }

    private var authPicker: some View {
        HStack(spacing: 8) {
            authOption(L10n.t("form.auth.key", language: language), icon: "key.fill", selected: !usePassword) { usePassword = false }
            authOption(L10n.t("form.auth.password", language: language), icon: "lock.fill", selected: usePassword) { usePassword = true }
        }
    }

    private func authOption(_ title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 10))
                Text(title).font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(selected ? Theme.purple : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? Theme.purple.opacity(0.12) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? Theme.purple.opacity(0.3) : Theme.inputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.borderless)
    }

    private var saveButton: some View {
        Button(action: save) {
            HStack(spacing: 8) {
                Image(systemName: isEditing ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .bold))
                Text(isEditing
                    ? L10n.t("form.saveEdit", language: language)
                    : L10n.t("form.saveCreate", language: language))
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: canSave
                                ? [Theme.purple, Theme.pink]
                                : [Theme.textTertiary, Theme.textTertiary],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(.borderless)
        .disabled(!canSave)
    }

    private var canSave: Bool {
        !name.isEmpty && !localPort.isEmpty && !remotePort.isEmpty
            && !sshHost.isEmpty && !sshUser.isEmpty
    }

    private func save() {
        guard let lp = Int(localPort),
              let rp = Int(remotePort),
              let sp = Int(sshPort) else { return }

        // If using ssh config host, store the alias so ssh reads its own config
        let finalSSHHost = selectedHostId ?? sshHost

        let config = TunnelConfig(
            id: editingTunnel?.id ?? UUID(),
            name: name,
            localPort: lp,
            remoteHost: remoteHost,
            remotePort: rp,
            sshHost: finalSSHHost,
            sshUser: sshUser,
            sshPort: sp,
            sshKeyPath: sshKeyPath.isEmpty ? nil : sshKeyPath,
            usePassword: usePassword,
            isReverse: isReverse,
            createdAt: editingTunnel?.createdAt ?? Date()
        )

        let pwd = password.isEmpty ? nil : password
        if isEditing {
            viewModel.updateTunnel(config, password: pwd)
        } else {
            viewModel.addTunnel(config, password: pwd)
        }
        dismiss()
    }
}
