import SwiftUI

// MARK: - Color Palette
enum Theme {
    private static var selectedTheme: AppTheme {
        AppTheme.from(code: UserDefaults.standard.string(forKey: AppTheme.storageKey) ?? AppTheme.defaultTheme.rawValue)
    }
    static var isLight: Bool { selectedTheme == .light }

    // Backgrounds
    static var bg: Color {
        switch selectedTheme {
        case .dark: return Color(red: 0.08, green: 0.07, blue: 0.14)
        case .light: return Color(red: 0.94, green: 0.95, blue: 0.98)
        case .cli: return Color.black
        case .christmas: return Color(red: 0.06, green: 0.13, blue: 0.10)
        }
    }
    static var cardBg: Color {
        switch selectedTheme {
        case .dark: return Color(red: 0.12, green: 0.11, blue: 0.20)
        case .light: return Color.white
        case .cli: return Color(red: 0.06, green: 0.07, blue: 0.08)
        case .christmas: return Color(red: 0.11, green: 0.19, blue: 0.14)
        }
    }
    static var cardBorder: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.08)
        default: return Color.white.opacity(0.08)
        }
    }
    static var inputBg: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.03)
        default: return Color.white.opacity(0.06)
        }
    }
    static var inputBorder: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.12)
        default: return Color.white.opacity(0.10)
        }
    }

    // Accents
    static var green: Color {
        switch selectedTheme {
        case .light: return Color(red: 0.08, green: 0.70, blue: 0.46)
        case .christmas: return Color(red: 0.24, green: 0.78, blue: 0.39)
        default: return Color(red: 0.29, green: 0.87, blue: 0.50)
        }
    }
    static var red: Color {
        switch selectedTheme {
        case .christmas: return Color(red: 0.84, green: 0.19, blue: 0.22)
        default: return Color(red: 0.96, green: 0.25, blue: 0.37)
        }
    }
    static var orange: Color { Color(red: 1.0, green: 0.65, blue: 0.0) }
    static var purple: Color {
        switch selectedTheme {
        case .cli: return Color(red: 0.39, green: 0.87, blue: 0.55)
        case .light: return Color(red: 0.49, green: 0.36, blue: 0.90)
        default: return Color(red: 0.55, green: 0.36, blue: 0.96)
        }
    }
    static var pink: Color {
        switch selectedTheme {
        case .christmas: return Color(red: 0.83, green: 0.28, blue: 0.45)
        case .cli: return Color(red: 0.24, green: 0.88, blue: 0.52)
        default: return Color(red: 0.93, green: 0.30, blue: 0.65)
        }
    }

    // Text
    static var textPrimary: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.9)
        default: return Color.white
        }
    }
    static var textSecondary: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.55)
        default: return Color.white.opacity(0.55)
        }
    }
    static var textTertiary: Color {
        switch selectedTheme {
        case .light: return Color.black.opacity(0.32)
        default: return Color.white.opacity(0.30)
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ConnectionStatus
    private let controlHeight: CGFloat = 28

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(dotColor)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(textColor)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(bgColor)
        )
        .overlay(
            Capsule().stroke(borderColor, lineWidth: 1)
        )
        .frame(height: controlHeight)
    }

    private var label: String {
        switch status {
        case .disconnected: return L10n.t("status.disconnected")
        case .connecting: return L10n.t("status.connecting")
        case .connected: return L10n.t("status.connected")
        case .error: return L10n.t("status.error")
        }
    }

    private var dotColor: Color {
        switch status {
        case .disconnected: return .gray
        case .connecting: return Theme.orange
        case .connected: return Theme.green
        case .error: return Theme.red
        }
    }

    private var textColor: Color {
        switch status {
        case .disconnected:
            return Theme.isLight ? Color.black.opacity(0.62) : Theme.textSecondary
        case .connecting:
            return Theme.isLight ? Color(red: 0.72, green: 0.43, blue: 0.0) : Theme.orange
        case .connected:
            return Theme.isLight ? Color(red: 0.03, green: 0.46, blue: 0.30) : Theme.green
        case .error:
            return Theme.isLight ? Color(red: 0.72, green: 0.16, blue: 0.22) : Theme.red
        }
    }

    private var bgColor: Color {
        switch status {
        case .disconnected:
            return Theme.isLight ? Color.black.opacity(0.08) : .gray.opacity(0.12)
        case .connecting:
            return Theme.isLight ? Theme.orange.opacity(0.18) : Theme.orange.opacity(0.12)
        case .connected:
            return Theme.isLight ? Theme.green.opacity(0.20) : Theme.green.opacity(0.12)
        case .error:
            return Theme.isLight ? Theme.red.opacity(0.20) : Theme.red.opacity(0.12)
        }
    }

    private var borderColor: Color {
        switch status {
        case .disconnected:
            return Theme.isLight ? Color.black.opacity(0.18) : .gray.opacity(0.2)
        case .connecting:
            return Theme.isLight ? Theme.orange.opacity(0.45) : Theme.orange.opacity(0.25)
        case .connected:
            return Theme.isLight ? Theme.green.opacity(0.45) : Theme.green.opacity(0.25)
        case .error:
            return Theme.isLight ? Theme.red.opacity(0.45) : Theme.red.opacity(0.25)
        }
    }
}

// MARK: - Toast Overlay
struct ToastView: View {
    let info: AlertInfo
    let onDismiss: () -> Void

    @State private var appear = false

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: info.isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(info.isError ? Theme.red : Theme.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(info.message)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(3)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.borderless)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.cardBg)
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(info.isError ? Theme.red.opacity(0.3) : Theme.green.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { appear = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { onDismiss() }
        }
    }
}

// MARK: - Themed Button
struct PillButton: View {
    let title: String
    let icon: String
    var color: Color = Theme.purple
    let action: () -> Void
    private let controlHeight: CGFloat = 28

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(color.opacity(0.12))
            )
            .overlay(
                Capsule().stroke(color.opacity(0.25), lineWidth: 1)
            )
            .frame(height: controlHeight)
        }
        .buttonStyle(.borderless)
    }
}
