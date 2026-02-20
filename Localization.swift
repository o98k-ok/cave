import Foundation

enum AppLanguage: String, CaseIterable {
    case zh
    case en
    case ja

    static let defaultLanguage: AppLanguage = .zh

    static func from(code: String) -> AppLanguage {
        AppLanguage(rawValue: code) ?? defaultLanguage
    }
}

enum L10n {
    static let languageKey = "app.language"

    static var currentLanguage: AppLanguage {
        let code = UserDefaults.standard.string(forKey: languageKey) ?? AppLanguage.defaultLanguage.rawValue
        return AppLanguage.from(code: code)
    }

    static func t(_ key: String, language: AppLanguage? = nil) -> String {
        let lang = language ?? currentLanguage
        return table[key]?[lang.rawValue] ?? key
    }

    private static let table: [String: [String: String]] = [
        "app.title": ["zh": "cave", "en": "cave", "ja": "cave"],
        "app.subtitle": ["zh": "SSH 隧道管理", "en": "SSH Tunnel Manager", "ja": "SSHトンネル管理"],
        "menu.accessibility": ["zh": "cave SSH 隧道", "en": "cave SSH Tunnel", "ja": "cave SSHトンネル"],
        "empty.noTunnel": ["zh": "暂无隧道", "en": "No tunnels yet", "ja": "トンネルはありません"],
        "action.addTunnel": ["zh": "添加隧道", "en": "Add Tunnel", "ja": "トンネル追加"],
        "lang.zh": ["zh": "ZH", "en": "ZH", "ja": "ZH"],
        "lang.en": ["zh": "EN", "en": "EN", "ja": "EN"],
        "lang.ja": ["zh": "JA", "en": "JA", "ja": "JA"],
        "action.settings": ["zh": "设置", "en": "Settings", "ja": "設定"],

        "status.disconnected": ["zh": "离线", "en": "OFFLINE", "ja": "オフライン"],
        "status.connecting": ["zh": "连接中", "en": "CONNECTING", "ja": "接続中"],
        "status.connected": ["zh": "已连接", "en": "CONNECTED", "ja": "接続済み"],
        "status.error": ["zh": "错误", "en": "ERROR", "ja": "エラー"],

        "action.confirmDelete": ["zh": "确认删除", "en": "Confirm Delete", "ja": "削除確認"],
        "action.cancel": ["zh": "取消", "en": "Cancel", "ja": "キャンセル"],
        "action.delete": ["zh": "删除", "en": "Delete", "ja": "削除"],
        "message.deleteConfirmFmt": ["zh": "确定要删除「%@」吗？", "en": "Delete \"%@\"?", "ja": "「%@」を削除しますか？"],
        "action.stop": ["zh": "停止", "en": "Stop", "ja": "停止"],
        "action.start": ["zh": "启动", "en": "Start", "ja": "開始"],
        "label.local": ["zh": "本地", "en": "Local", "ja": "ローカル"],
        "label.port": ["zh": "PORT", "en": "PORT", "ja": "PORT"],
        "message.copied": ["zh": "已复制", "en": "Copied", "ja": "コピー済み"],
        "message.clickToCopyFmt": ["zh": "点击复制: %@", "en": "Click to copy: %@", "ja": "クリックしてコピー: %@"],

        "form.editTunnel": ["zh": "编辑隧道", "en": "Edit Tunnel", "ja": "トンネル編集"],
        "form.createTunnel": ["zh": "添加隧道", "en": "Add Tunnel", "ja": "トンネル追加"],
        "form.section.basic": ["zh": "基本信息", "en": "Basic Info", "ja": "基本情報"],
        "form.name": ["zh": "名称", "en": "Name", "ja": "名前"],
        "form.name.placeholder": ["zh": "例如: 开发数据库", "en": "e.g. Dev Database", "ja": "例: 開発DB"],
        "form.section.direction": ["zh": "隧道方向", "en": "Tunnel Direction", "ja": "トンネル方向"],
        "form.forward.title": ["zh": "正向 -L", "en": "Forward -L", "ja": "順方向 -L"],
        "form.forward.desc": ["zh": "本地访问远程服务", "en": "Local to remote service", "ja": "ローカルからリモートへ"],
        "form.reverse.title": ["zh": "反向 -R", "en": "Reverse -R", "ja": "逆方向 -R"],
        "form.reverse.desc": ["zh": "远程访问本地服务", "en": "Remote to local service", "ja": "リモートからローカルへ"],
        "form.section.mapping": ["zh": "端口映射", "en": "Port Mapping", "ja": "ポートマッピング"],
        "form.localPort": ["zh": "本地端口", "en": "Local Port", "ja": "ローカルポート"],
        "form.localPortService": ["zh": "本地端口 (服务)", "en": "Local Port (Service)", "ja": "ローカルポート (サービス)"],
        "form.remotePort": ["zh": "远程端口", "en": "Remote Port", "ja": "リモートポート"],
        "form.remotePortExpose": ["zh": "远程端口 (暴露)", "en": "Remote Port (Expose)", "ja": "リモートポート (公開)"],
        "form.remoteHost": ["zh": "远程主机", "en": "Remote Host", "ja": "リモートホスト"],
        "form.localBind": ["zh": "本地绑定地址", "en": "Local Bind Address", "ja": "ローカルバインドアドレス"],
        "form.section.ssh": ["zh": "SSH 服务器", "en": "SSH Server", "ja": "SSHサーバー"],
        "form.manualInput": ["zh": "手动输入", "en": "Manual", "ja": "手動入力"],
        "form.host": ["zh": "主机", "en": "Host", "ja": "ホスト"],
        "form.user": ["zh": "用户名", "en": "User", "ja": "ユーザー"],
        "form.port": ["zh": "端口", "en": "Port", "ja": "ポート"],
        "form.section.auth": ["zh": "认证方式", "en": "Authentication", "ja": "認証方式"],
        "form.auth.key": ["zh": "SSH 密钥", "en": "SSH Key", "ja": "SSHキー"],
        "form.auth.password": ["zh": "密码", "en": "Password", "ja": "パスワード"],
        "form.password": ["zh": "密码", "en": "Password", "ja": "パスワード"],
        "form.password.placeholder": ["zh": "输入密码", "en": "Enter password", "ja": "パスワード入力"],
        "form.keyPath": ["zh": "密钥路径", "en": "Key Path", "ja": "キーパス"],
        "form.saveEdit": ["zh": "保存修改", "en": "Save Changes", "ja": "変更を保存"],
        "form.saveCreate": ["zh": "创建隧道", "en": "Create Tunnel", "ja": "トンネル作成"],

        "alert.connectedTitle": ["zh": "连接成功", "en": "Connected", "ja": "接続成功"],
        "alert.connectedMessageFmt": ["zh": "%@\nlocalhost:%d → %@:%d", "en": "%@\nlocalhost:%d -> %@:%d", "ja": "%@\nlocalhost:%d -> %@:%d"],
        "alert.failedTitle": ["zh": "连接失败", "en": "Connection Failed", "ja": "接続失敗"],
        "alert.disconnectedTitle": ["zh": "连接断开", "en": "Disconnected", "ja": "切断"],
        "alert.processEndedFmt": ["zh": "%@ 进程已终止", "en": "%@ process terminated", "ja": "%@ プロセスが終了しました"],
        "error.processExitFmt": ["zh": "进程退出 (code: %d)", "en": "Process exited (code: %d)", "ja": "プロセス終了 (code: %d)"],
        "error.startFailedFmt": ["zh": "启动失败: %@", "en": "Failed to start: %@", "ja": "起動失敗: %@"],
        "error.processDiedEarly": ["zh": "进程启动后立即退出", "en": "Process exited immediately after start", "ja": "起動直後に終了しました"],
        "error.connectionTimeout": ["zh": "连接超时（20秒内端口未就绪）", "en": "Connection timeout (port not ready in 20s)", "ja": "接続タイムアウト（20秒でポート未準備）"],
        "error.processUnexpectedExit": ["zh": "进程意外终止", "en": "Process terminated unexpectedly", "ja": "プロセスが異常終了しました"],

        "settings.title": ["zh": "设置", "en": "Settings", "ja": "設定"],
        "settings.general": ["zh": "通用", "en": "General", "ja": "一般"],
        "settings.launchAtLogin": ["zh": "开机启动", "en": "Launch at Login", "ja": "ログイン時に起動"],
        "settings.language": ["zh": "语言", "en": "Language", "ja": "言語"],
        "settings.theme": ["zh": "主题", "en": "Theme", "ja": "テーマ"],
        "settings.theme.dark": ["zh": "深色", "en": "Dark", "ja": "ダーク"],
        "settings.theme.light": ["zh": "浅色", "en": "Light", "ja": "ライト"],
        "settings.theme.cli": ["zh": "CLI", "en": "CLI", "ja": "CLI"],
        "settings.theme.christmas": ["zh": "圣诞", "en": "Christmas", "ja": "クリスマス"],
        "settings.danger": ["zh": "应用", "en": "App", "ja": "アプリ"],
        "settings.quit": ["zh": "退出应用", "en": "Quit App", "ja": "アプリ終了"],
        "settings.quitHint": ["zh": "将优雅关闭所有 SSH 隧道后退出", "en": "Gracefully stop all SSH tunnels before quitting", "ja": "全SSHトンネルを停止して終了します"]
    ]
}
