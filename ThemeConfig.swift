import Foundation

enum AppTheme: String, CaseIterable {
    case dark
    case light
    case cli
    case christmas

    static let storageKey = "app.theme"
    static let defaultTheme: AppTheme = .dark

    static func from(code: String) -> AppTheme {
        AppTheme(rawValue: code) ?? defaultTheme
    }
}
