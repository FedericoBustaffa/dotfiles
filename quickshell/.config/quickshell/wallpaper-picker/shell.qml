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
import "./theme/Fuzzy.js" as Fuzzy

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
                card.dismiss();
            } else {
                root.errorMessage = errors.text.trim() || reply.text.trim()
                    || "Could not reach hyprpaper.";
            }
        }
    }

    function apply(): void {
        if (applyProcess.running || grid.currentIndex < 0 || grid.currentIndex >= grid.count)
            return;
        const path = grid.model[grid.currentIndex].filePath;
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
        color: card.scrim(Theme.wallpaperScrim)
        WlrLayershell.namespace: "wallpaper-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        onVisibleChanged: if (visible) search.forceActiveFocus()

        Item {
            id: surface
            anchors.fill: parent
            Keys.onEscapePressed: if (!applyProcess.running) card.dismissFromKeyboard()

            TapHandler {
                onTapped: point => {
                    if (!applyProcess.running && !card.contains(card.mapFromItem(surface, point.position)))
                        card.dismiss();
                }
            }

            DropUpCard {
                id: card
                presented: picker.visible
                width: Math.min(960, surface.width - 40)
                height: Math.min(640, surface.height - 40)
                color: Theme.background
                border.color: Theme.outline

                ColumnLayout {
                    anchors { fill: parent; margins: 20 }
                    spacing: 12

                    Text {
                        text: "Wallpapers"
                        font { pixelSize: Theme.menuTitleFontSize; bold: true }
                        color: Theme.foreground
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "~/dotfiles/wallpapers  ·  Applies to all displays"
                        font.pixelSize: Theme.menuSubtitleFontSize
                        color: Theme.muted
                        elide: Text.ElideRight
                    }

                    TextField {
                        id: search
                        Layout.fillWidth: true
                        placeholderText: "Search wallpapers…"
                        font.pixelSize: Theme.menuBodyFontSize
                        color: Theme.menuText()
                        background: Rectangle { radius: 8; color: Theme.raised; border.color: Theme.outline }
                        onAccepted: root.apply()
                        Keys.onDownPressed: if (grid.count) grid.forceActiveFocus()
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridView {
                            id: grid
                            anchors { fill: parent; rightMargin: 10 }
                            clip: true
                            focus: true
                            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 205)))
                            cellHeight: Math.round(cellWidth * 0.62) + 26
                            model: {
                                const entries = [];
                                for (let i = 0; i < images.count; i++)
                                    entries.push({ fileName: images.get(i, "fileName"), filePath: images.get(i, "filePath"),
                                        fileUrl: images.get(i, "fileUrl") });
                                return Fuzzy.search(entries, search.text, entry => entry.fileName);
                            }
                            onModelChanged: { currentIndex = model.length ? 0 : -1; positionViewAtBeginning(); }
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Keys.onReturnPressed: event => { if (!event.isAutoRepeat) root.apply(); }
                            Keys.onEnterPressed: event => { if (!event.isAutoRepeat) root.apply(); }

                            delegate: Item {
                                id: tile
                                required property int index
                                required property var modelData
                                readonly property string fileName: modelData.fileName
                                readonly property url fileUrl: modelData.fileUrl
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
                                            font.pixelSize: Theme.menuBodyFontSize
                                            textFormat: Text.PlainText
                                            elide: Text.ElideRight
                                            color: Theme.menuText(grid.currentIndex === tile.index)
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: grid.count === 0
                            text: images.status === FolderListModel.Loading ? "Loading wallpapers…" : "No matching wallpapers."
                            font.pixelSize: Theme.menuBodyFontSize
                            color: Theme.muted
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            Layout.fillWidth: true
                            text: root.errorMessage || "Arrow keys to browse  ·  Enter to apply  ·  Esc to close"
                            font.pixelSize: Theme.menuBodyFontSize
                            textFormat: Text.PlainText
                            color: root.errorMessage ? Theme.errorText : Theme.muted
                            wrapMode: Text.Wrap
                        }

                        Button {
                            id: applyButton
                            text: applyProcess.running ? "Applying…" : "Apply wallpaper"
                            font.pixelSize: Theme.menuBodyFontSize
                            contentItem: Text {
                                text: applyButton.text
                                font: applyButton.font
                                color: Theme.menuText()
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: 8
                                color: !applyButton.enabled ? Theme.disabled : applyButton.hovered ? Theme.buttonHover : Theme.button
                                border.color: applyButton.enabled ? Theme.accent : Theme.outline
                            }
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
