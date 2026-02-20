import SwiftUI

struct TunnelListView: View {
    @ObservedObject var viewModel: TunnelViewModel
    @AppStorage(L10n.languageKey) private var languageCode = AppLanguage.defaultLanguage.rawValue

    private var language: AppLanguage { AppLanguage.from(code: languageCode) }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 0) {
                header
                tunnelList
            }

            if let alert = viewModel.alert {
                ToastView(info: alert) { viewModel.alert = nil }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if viewModel.showingSettings {
                SettingsView(viewModel: viewModel) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showingSettings = false
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .frame(width: 460, height: 500)
        .sheet(isPresented: $viewModel.showingForm) {
            TunnelFormView(
                viewModel: viewModel,
                editingTunnel: viewModel.editingTunnel
            )
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Theme.purple, Theme.pink],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: "smallcircle.filled.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.t("app.title", language: language))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer()

            Button(action: viewModel.showSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle().fill(Color.white.opacity(0.05))
                    )
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            .buttonStyle(.borderless)
            .help(L10n.t("action.settings", language: language))

            // Active count badge
            let activeCount = viewModel.tunnels.filter {
                viewModel.state(for: $0.id).status == .connected
            }.count

            if activeCount > 0 {
                StatusBadge(status: .connected)
            }

            // Add button
            Button(action: viewModel.showAddForm) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.purple)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle().fill(Theme.purple.opacity(0.12))
                    )
                    .overlay(
                        Circle().stroke(Theme.purple.opacity(0.25), lineWidth: 1)
                    )
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            Theme.cardBg.opacity(0.6)
        )
        .overlay(alignment: .bottom) {
            Divider().background(Theme.cardBorder)
        }
    }

    // MARK: - List

    @ViewBuilder
    private var tunnelList: some View {
        if viewModel.tunnels.isEmpty {
            emptyState
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.tunnels) { tunnel in
                        TunnelRowView(
                            config: tunnel,
                            state: viewModel.state(for: tunnel.id),
                            onToggle: { viewModel.toggleTunnel(tunnel) },
                            onEdit: { viewModel.showEditForm(tunnel) },
                            onDelete: { viewModel.deleteTunnel(tunnel) }
                        )
                    }
                }
                .padding(14)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.purple.opacity(0.08))
                    .frame(width: 72, height: 72)
                Image(systemName: "network.slash")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.textTertiary)
            }
            Text(L10n.t("empty.noTunnel", language: language))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            PillButton(title: L10n.t("action.addTunnel", language: language), icon: "plus") {
                viewModel.showAddForm()
            }
            Spacer()
        }
    }
}
