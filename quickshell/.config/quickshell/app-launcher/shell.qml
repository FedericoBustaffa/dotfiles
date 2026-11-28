pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./theme"
import "./theme/Fuzzy.js" as Fuzzy

ShellRoot {
    id: root
    readonly property var commands: [
        { name: "Theme picker", icon: "preferences-desktop-theme", menu: "theme", keywords: ["appearance", "colors", "palette"] },
        { name: "Wallpaper picker", icon: "preferences-desktop-wallpaper", menu: "wallpaper-picker", keywords: ["background", "appearance"] },
        { name: "Wi-Fi manager", icon: "network-wireless", menu: "network-manager", keywords: ["connectivity", "network", "internet"] },
        { name: "Bluetooth manager", icon: "bluetooth", menu: "bluetooth-manager", keywords: ["connectivity", "devices", "pair"] },
        { name: "Notifications", icon: "preferences-system-notifications", keywords: ["alerts", "dnd"] },
        { name: "Power menu", icon: "system-shutdown", menu: "power-menu", keywords: ["shutdown", "reboot", "logout", "lock", "suspend"] }
    ]

    function runShellCommand(command: string): void {
        if (!command.trim()) return;
        // Pass the command as data to the wrapper; only Bash interprets its text.
        Quickshell.execDetached({
            command: ["env", "-u", "BASH_ENV", "sh", "-c",
                'exec bash --noprofile --norc -c "$1" </dev/null >/dev/null 2>&1', "launcher", command],
            workingDirectory: Quickshell.env("HOME")
        });
        Qt.quit();
    }

    function launch(app) {
        if (!app) return;
        if (search.commandMode) {
            const base = Quickshell.shellDir + "/..";
            const command = app.menu
                ? ["env", "QUICKSHELL_PALETTE_PARENT=" + search.text, "quickshell", "-n", "-p", base + "/" + app.menu]
                : ["quickshell", "ipc", "-p", base + "/top-dock", "call", "notifications", "openFromPalette", search.text];
            Quickshell.execDetached(command);
        } else if (app.runInTerminal) {
            Quickshell.execDetached({ command: ["kitty", "--", ...app.command], workingDirectory: app.workingDirectory });
        } else {
            app.execute();
        }
        Qt.quit();
    }

    PanelWindow {
        screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: Theme.managerScrim
        WlrLayershell.namespace: "app-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: surface
            anchors.fill: parent
            TapHandler {
                onTapped: point => {
                    if (!card.contains(card.mapFromItem(surface, point.position))) Qt.quit();
                }
            }

            DropUpCard {
                id: card
                width: Math.min(560, surface.width - 32)
                height: Math.min(search.shellMode ? 116 : 470, surface.height - 32)
                color: Theme.background
                border.color: Theme.outline

                TextField {
                    id: search
                    readonly property bool commandMode: text.startsWith(">")
                    readonly property bool shellMode: text.startsWith("$")
                    text: Quickshell.env("QUICKSHELL_PALETTE_QUERY")
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                    height: 42
                    leftPadding: 12
                    rightPadding: 12
                    placeholderText: "Search apps · > commands · $ Bash"
                    placeholderTextColor: Theme.muted
                    color: Theme.foreground
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.background
                    selectByMouse: true
                    font.pixelSize: Theme.menuBodyFontSize
                    focus: true
                    Component.onCompleted: {
                        cursorPosition = text.length;
                        forceActiveFocus();
                    }
                    background: Rectangle { radius: 9; color: Theme.raised; border.color: Theme.outline }
                    onAccepted: {
                        if (shellMode) root.runShellCommand(text.slice(1));
                        else root.launch(results.model[results.currentIndex]);
                    }
                    Keys.onEscapePressed: Qt.quit()
                    Keys.onDownPressed: if (results.count) results.currentIndex = (results.currentIndex + 1) % results.count
                    Keys.onUpPressed: if (results.count) results.currentIndex = (results.currentIndex + results.count - 1) % results.count
                }

                ListView {
                    id: results
                    anchors { top: search.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16; topMargin: 10 }
                    clip: true
                    spacing: 4
                    keyNavigationEnabled: false
                    visible: !search.shellMode
                    model: {
                        if (search.shellMode) return [];
                        const entries = search.commandMode ? root.commands
                            : DesktopEntries.applications.values.filter(app => app.name && !app.noDisplay && app.command.length)
                                .sort((a, b) => a.name.localeCompare(b.name));
                        return Fuzzy.search(entries, search.commandMode ? search.text.slice(1) : search.text,
                            app => app.name, app => [app.genericName, app.id, app.comment,
                                ...(app.categories ?? []), ...(app.keywords ?? [])]);
                    }
                    onModelChanged: {
                        currentIndex = count ? 0 : -1;
                        positionViewAtBeginning();
                    }
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        readonly property bool selected: ListView.isCurrentItem
                        width: results.width - 9
                        height: 46
                        radius: 8
                        color: selected ? Theme.outline : hover.hovered ? Theme.raised : "transparent"
                        Accessible.role: Accessible.Button
                        Accessible.name: modelData.name

                        Image {
                            id: icon
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            width: 28
                            height: 28
                            source: (row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : "")
                                || Quickshell.iconPath("application-x-executable", true)
                            sourceSize { width: 32; height: 32 }
                            fillMode: Image.PreserveAspectFit
                            Text {
                                anchors.centerIn: parent
                                visible: icon.status === Image.Error || icon.status === Image.Null
                                text: row.modelData.name.charAt(0).toUpperCase()
                                color: Theme.muted
                                font.pixelSize: Theme.subtitleFontSize
                            }
                        }
                        Text {
                            anchors { left: icon.right; leftMargin: 12; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            text: row.modelData.name
                            textFormat: Text.PlainText
                            color: Theme.menuText(row.selected)
                            font.pixelSize: Theme.menuBodyFontSize
                            elide: Text.ElideRight
                        }
                        HoverHandler { id: hover }
                        TapHandler { onTapped: root.launch(row.modelData) }
                    }
                }

                Text {
                    anchors.centerIn: results
                    visible: search.shellMode || results.count === 0
                    text: search.shellMode ? "Run a Bash command · starts in ~ · no terminal"
                        : search.commandMode ? "No matching commands" : "No matching applications"
                    color: Theme.muted
                    font.pixelSize: Theme.menuBodyFontSize
                }
            }
        }
    }
}
