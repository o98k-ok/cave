import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TunnelViewModel
    let onClose: () -> Void

    @AppStorage(L10n.languageKey) private var languageCode = AppLanguage.defaultLanguage.rawValue
    @AppStorage(AppTheme.storageKey) private var themeCode = AppTheme.defaultTheme.rawValue
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled()

    private var language: AppLanguage { AppLanguage.from(code: languageCode) }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 12) {
                header

                sectionTitle(L10n.t("settings.general", language: language))
                VStack(spacing: 12) {
                    HStack {
                        Text(L10n.t("settings.launchAtLogin", language: language))
                        Spacer()
                        Toggle("", isOn: $launchAtLogin)
                            .labelsHidden()
                            .onChange(of: launchAtLogin) { value in
                                do { try LaunchAtLoginManager.setEnabled(value) } catch { launchAtLogin = LaunchAtLoginManager.isEnabled() }
                            }
                    }
                    .frame(height: 28)

                    HStack(alignment: .center, spacing: 8) {
                        Text(L10n.t("settings.language", language: language))
                        Spacer()
                        HStack(spacing: 6) {
                            choiceChip("ZH", selected: languageCode == AppLanguage.zh.rawValue) { languageCode = AppLanguage.zh.rawValue }
                            choiceChip("EN", selected: languageCode == AppLanguage.en.rawValue) { languageCode = AppLanguage.en.rawValue }
                            choiceChip("JA", selected: languageCode == AppLanguage.ja.rawValue) { languageCode = AppLanguage.ja.rawValue }
                        }
                    }
                    .frame(height: 30)

                    HStack(alignment: .center, spacing: 8) {
                        Text(L10n.t("settings.theme", language: language))
                        Spacer()
                        HStack(spacing: 6) {
                            themeChip(.dark)
                            themeChip(.light)
                            themeChip(.cli)
                            themeChip(.christmas)
                        }
                    }
                    .frame(height: 30)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.cardBg.opacity(0.5)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 1))

                sectionTitle(L10n.t("settings.danger", language: language))
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.t("settings.quitHint", language: language))
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                    Button(action: {
                        viewModel.shutdownAndQuit()
                    }) {
                        Text(L10n.t("settings.quit", language: language))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(Color(red: 0.82, green: 0.24, blue: 0.30))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.borderless)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.cardBg.opacity(0.5)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.cardBorder, lineWidth: 1))
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(width: 460, height: 500)
    }

    private var header: some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.borderless)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
        }
    }

    private func themeChip(_ theme: AppTheme) -> some View {
        let title: String
        switch theme {
        case .dark: title = L10n.t("settings.theme.dark", language: language)
        case .light: title = L10n.t("settings.theme.light", language: language)
        case .cli: title = L10n.t("settings.theme.cli", language: language)
        case .christmas: title = L10n.t("settings.theme.christmas", language: language)
        }
        return choiceChip(title, selected: themeCode == theme.rawValue) { themeCode = theme.rawValue }
    }

    private func choiceChip(_ text: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selected ? Theme.green : Theme.textSecondary)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(
                    Capsule().fill(selected ? Theme.green.opacity(0.16) : Color.white.opacity(0.06))
                )
                .overlay(
                    Capsule().stroke(selected ? Theme.green.opacity(0.35) : Theme.cardBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.borderless)
    }
}
