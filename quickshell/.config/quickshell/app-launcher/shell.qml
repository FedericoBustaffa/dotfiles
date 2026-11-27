pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    function normalize(text) {
        return (text ?? "").toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
    }

    function rank(app, query, words) {
        const name = normalize(app.name);
        if (!query || name === query) return 0;
        if (name.startsWith(query)) return 1;
        if (name.includes(query)) return 2;
        if (words.every(word => name.includes(word))) return 3;
        const details = [name, app.genericName, app.id, app.comment, ...app.categories, ...app.keywords];
        return words.every(word => details.some(value => normalize(value).includes(word))) ? 4 : -1;
    }

    function launch(app) {
        if (!app) return;
        if (app.runInTerminal) {
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

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: Math.min(560, surface.width - 32)
                height: Math.min(470, surface.height - 32)
                radius: 18
                color: Theme.background
                border.color: Theme.outline

                TextField {
                    id: search
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
                    height: 42
                    leftPadding: 12
                    rightPadding: 12
                    placeholderText: "Search applications…"
                    placeholderTextColor: Theme.muted
                    color: Theme.foreground
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.background
                    selectByMouse: true
                    font.pixelSize: 16
                    focus: true
                    Component.onCompleted: forceActiveFocus()
                    background: Rectangle { radius: 9; color: Theme.raised; border.color: Theme.outline }
                    onAccepted: root.launch(results.model[results.currentIndex])
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
                    model: {
                        const query = root.normalize(search.text).trim();
                        const words = query.split(/\s+/);
                        return DesktopEntries.applications.values.filter(app => app.name && !app.noDisplay && app.command.length)
                            .map(app => ({ app: app, rank: root.rank(app, query, words) }))
                            .filter(result => result.rank >= 0)
                            .sort((a, b) => a.rank - b.rank || a.app.name.localeCompare(b.app.name))
                            .map(result => result.app);
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
                            source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, "application-x-executable") : Quickshell.iconPath("application-x-executable")
                            sourceSize { width: 32; height: 32 }
                            fillMode: Image.PreserveAspectFit
                            Text {
                                anchors.centerIn: parent
                                visible: icon.status === Image.Error || icon.status === Image.Null
                                text: row.modelData.name.charAt(0).toUpperCase()
                                color: Theme.muted
                                font.pixelSize: 16
                            }
                        }
                        Text {
                            anchors { left: icon.right; leftMargin: 12; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            text: row.modelData.name
                            textFormat: Text.PlainText
                            color: row.selected ? Theme.accent : Theme.foreground
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }
                        HoverHandler { id: hover }
                        TapHandler { onTapped: root.launch(row.modelData) }
                    }
                }

                Text {
                    anchors.centerIn: results
                    visible: results.count === 0
                    text: "No matching applications"
                    color: Theme.muted
                }
            }
        }
    }
}
