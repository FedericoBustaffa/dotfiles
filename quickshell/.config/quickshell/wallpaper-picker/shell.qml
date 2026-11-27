pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    readonly property string directory: Quickshell.env("HOME") + "/dotfiles/wallpapers"
    readonly property color accent: Theme.accent
    property string monitorName: ""
    property string errorMessage: ""

    Component.onCompleted: {
        root.monitorName = Hyprland.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
        picker.visible = true;
    }

    FolderListModel {
        id: images
        folder: "file://" + encodeURI(root.directory)
        showDirs: false
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.bmp"]
        sortField: FolderListModel.Name
    }

    Process {
        id: applyProcess
        stdout: StdioCollector { id: reply }
        stderr: StdioCollector { id: errors }
        onExited: (code, status) => {
            if (code === 0 && status === 0) {
                Qt.quit();
            } else {
                root.errorMessage = errors.text.trim() || reply.text.trim()
                    || "Could not reach hyprpaper.";
            }
        }
    }

    function apply(): void {
        if (applyProcess.running || grid.currentIndex < 0 || grid.currentIndex >= images.count)
            return;
        const path = images.get(grid.currentIndex, "filePath");
        if (path.includes(",")) {
            root.errorMessage = "Hyprpaper does not accept commas in wallpaper paths.";
            return;
        }
        root.errorMessage = "";
        applyProcess.command = ["bash", Quickshell.env("HOME") + "/dotfiles/scripts/hyprpaper-state.sh",
            "apply", path];
        applyProcess.running = true;
    }

    PanelWindow {
        id: picker
        visible: false
        screen: Quickshell.screens.find(screen => screen.name === root.monitorName)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        // Hyprland blurs behind this translucent surface.
        color: Theme.wallpaperScrim
        WlrLayershell.namespace: "wallpaper-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        onVisibleChanged: if (visible) grid.forceActiveFocus()

        Item {
            id: surface
            anchors.fill: parent
            Keys.onEscapePressed: if (!applyProcess.running) Qt.quit()

            TapHandler {
                onTapped: point => {
                    if (!applyProcess.running && !card.contains(card.mapFromItem(surface, point.position)))
                        Qt.quit();
                }
            }

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: Math.min(960, surface.width - 40)
                height: Math.min(640, surface.height - 40)
                radius: 18
                color: Theme.background
                border.color: Theme.outline

                ColumnLayout {
                    anchors { fill: parent; margins: 20 }
                    spacing: 12

                    Text {
                        text: "Wallpapers"
                        font { pixelSize: 24; bold: true }
                        color: Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "~/dotfiles/wallpapers  ·  Applies to all displays"
                        color: Theme.muted
                        elide: Text.ElideRight
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridView {
                            id: grid
                            anchors { fill: parent; rightMargin: 10 }
                            clip: true
                            focus: true
                            currentIndex: images.count > 0 ? 0 : -1
                            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 205)))
                            cellHeight: Math.round(cellWidth * 0.62) + 26
                            model: images
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Keys.onReturnPressed: event => { if (!event.isAutoRepeat) root.apply(); }
                            Keys.onEnterPressed: event => { if (!event.isAutoRepeat) root.apply(); }

                            delegate: Item {
                                id: tile
                                required property int index
                                required property string fileName
                                required property url fileUrl
                                width: grid.cellWidth
                                height: grid.cellHeight

                                Button {
                                    id: thumbnail
                                    anchors { fill: parent; margins: 4 }
                                    hoverEnabled: true
                                    focusPolicy: Qt.NoFocus
                                    padding: 5
                                    Accessible.name: tile.fileName
                                    onClicked: {
                                        grid.currentIndex = tile.index;
                                        grid.forceActiveFocus();
                                    }
                                    background: Rectangle {
                                        radius: 9
                                        color: thumbnail.hovered || grid.currentIndex === tile.index ? Theme.surface("#30363c") : Theme.raised
                                        border.color: grid.currentIndex === tile.index ? root.accent : Theme.surface("#3b3d46")
                                        border.width: grid.currentIndex === tile.index ? 2 : 1
                                    }
                                    contentItem: ColumnLayout {
                                        spacing: 4
                                        Image {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            source: tile.fileUrl
                                            sourceSize: Qt.size(320, 240)
                                            asynchronous: true
                                            fillMode: Image.PreserveAspectCrop
                                            clip: true
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: tile.fileName
                                            textFormat: Text.PlainText
                                            elide: Text.ElideRight
                                            color: Theme.foreground
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: images.count === 0
                            text: images.status === FolderListModel.Loading ? "Loading wallpapers…" : "No supported images found."
                            color: Theme.muted
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            Layout.fillWidth: true
                            text: root.errorMessage || "Arrow keys to browse  ·  Enter to apply  ·  Esc to close"
                            textFormat: Text.PlainText
                            color: root.errorMessage ? Theme.errorText : Theme.muted
                            wrapMode: Text.Wrap
                        }

                        Button {
                            text: applyProcess.running ? "Applying…" : "Apply wallpaper"
                            enabled: grid.currentIndex >= 0 && !applyProcess.running
                            focusPolicy: Qt.NoFocus
                            onClicked: root.apply()
                        }
                    }
                }
            }
        }
    }
}
