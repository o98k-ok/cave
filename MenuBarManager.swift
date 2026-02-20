import SwiftUI
import AppKit

final class MenuBarManager {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let viewModel = TunnelViewModel()

    init() {
        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "smallcircle.filled.circle.fill",
                accessibilityDescription: L10n.t("menu.accessibility")
            )
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 460, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: TunnelListView(viewModel: viewModel)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            popover.close()
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
