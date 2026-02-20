# cave

A macOS menu bar app for managing SSH tunnels.

## 主要功能

- 菜单栏常驻：快速管理 SSH 隧道（正向 `-L` / 反向 `-R`）
- 隧道列表：一键启动/停止、编辑、删除、状态可视化
- 节点链路：本地 / Proxy / Target 一目了然，并支持点击复制
- 国际化：支持 `ZH / EN / JA`，默认中文
- 主题：`Dark / Light / CLI / Christmas`
- 设置中心：开机启动、语言、主题、优雅退出（先关闭隧道）

## 环境要求

- macOS 13+
- Xcode Command Line Tools（包含 `swift`）

## 本地构建与运行

### 调试构建

```bash
swift build
```

### 打包 `.app`

```bash
./build.sh
open build/cave.app
```

## 发布产物（GitHub Actions）

仓库已配置自动构建 DMG：

- `push` 到 `main`：自动构建并上传 `cave.dmg` 为 workflow artifact
- `tag`（如 `v1.0.0`）：自动创建/更新 GitHub Release 并附带 `cave.dmg`

工作流文件：`.github/workflows/build-dmg.yml`

说明：该工作流会分别构建 `arm64` 与 `x86_64`，再合并为通用二进制（Universal）并打包成 `cave.dmg`。
可在手动触发时选择：
- `upload_release=false`：仅生成 artifact
- `upload_release=true` + `tag=vX.Y.Z`：同时上传到对应 Release
