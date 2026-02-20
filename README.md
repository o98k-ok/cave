# cave

A macOS menu bar app for managing SSH tunnels.

**Languages:** [中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

## 主要功能

- 菜单栏常驻：快速管理 SSH 隧道（正向 `-L` / 反向 `-R`）
- 隧道列表：一键启动/停止、编辑、删除、状态可视化
- 节点链路：本地 / Proxy / Target 一目了然，并支持点击复制
- 国际化：支持 `ZH / EN / JA`，默认中文
- 主题：`Dark / Light / CLI / Christmas`
- 设置中心：开机启动、语言、主题、优雅退出（先关闭隧道）

## 功能演示

### 主界面
![主界面](docs/screenshots/main-interface.png)

### 添加隧道
![添加隧道](docs/screenshots/add-tunnel.png)

### 设置中心
![设置中心](docs/screenshots/settings.png)

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
