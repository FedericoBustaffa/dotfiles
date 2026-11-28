# Quickshell widgets

## Where changes belong

- `top-dock/shell.qml` wires up desktop services and composes one dock per screen. `DockPanel.qml` owns the three anchored control groups, input region, and drawer placement. `WorkspaceStrip.qml` owns monitor filtering and workspace animations.
- For a new hover menu, reuse `HoverReveal.qml` for pointer handoff and animation, and register the button and menu together in the dock's `sideDrawers` list. Keep settings actions separate from opening the hover menu. Reuse `ConnectionDrawer.qml` for a short list of saved connections.
- `theme/Theme.qml` owns palette and typography. `theme/SelectionOutline.qml` is for selected or focused controls, not passive dividers. Keep widget-specific behavior in its own config; extract shared code only when it has multiple callers.
- Run `git diff --check`, check the live dock log with `quickshell log -p "$PWD/quickshell/.config/quickshell/top-dock"`, and smoke-test the affected widget. Opening a widget should not change a connection, profile, or wallpaper.

## Floating overlays

Use `theme/DropUpCard.qml` for full-screen menu overlays: the card slides up
from the bottom edge while the compositor retains its existing fade. Bind
`presented` to the overlay's open state if the window is reused. Register new
floating menus in the app launcher's `commands` list so they appear after `>`.

## Drawer design

For new popups, dropdowns, and dashboards that open from the top dock, make the panel look like an extension of the dock rather than a floating pill. Join it directly to the bar with rounded, concave shoulders, and keep the exposed bottom corners rounded. Reuse `top-dock/DrawerJoin.qml` as the reference implementation (under `.config/quickshell/`). The resource and volume drawers are the reference designs. Center narrow drawers on their triggering buttons. The bar spans the entire top edge of each display, with its controls centered. Drawers must not resize or shift the bar. Keep live status readouts in fixed-width slots so only the workspace strip changes width during normal use.
