pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
    readonly property color accent: Theme.accent
    readonly property var actions: [
        { label: "Shutdown", key: Qt.Key_S, hint: "S", icon: "\uf011", command: [Quickshell.env("HOME") + "/dotfiles/scripts/pre_poweroff.sh"], confirm: true },
        { label: "Reboot", key: Qt.Key_R, hint: "R", icon: "\uf021", command: ["systemctl", "reboot"], confirm: true },
        { label: "Suspend", key: Qt.Key_U, hint: "U", icon: "\uf186", command: ["systemctl", "suspend"] },
        { label: "Log Out", key: Qt.Key_E, hint: "E", icon: "\uf08b", command: ["hyprctl", "dispatch", "hl.dsp.exit()"], confirm: true },
        { label: "Lock Screen", key: Qt.Key_L, hint: "L", icon: "\uf023", command: ["loginctl", "lock-session"] }
    ]
    property int selectedIndex: actions.length - 1
    property var pendingAction: null
    property bool confirmSelected: false

    function runAction(action): void {
        Quickshell.execDetached(action.command);
        Qt.quit();
    }

    function choose(index: int): void {
        selectedIndex = index;
        const action = actions[index];
        if (action.confirm) {
            confirmSelected = false;
            pendingAction = action;
        } else {
            runAction(action);
        }
    }

    function handleKey(event): void {
        const enter = event.key === Qt.Key_Return || event.key === Qt.Key_Enter;
        const left = event.key === Qt.Key_Left;
        const right = event.key === Qt.Key_Right;
        if (event.key === Qt.Key_Escape) {
            if (pendingAction)
                pendingAction = null;
            else
                Qt.quit();
        } else if (pendingAction) {
            if (left || right)
                confirmSelected = right;
            else if (enter && !event.isAutoRepeat) {
                if (confirmSelected)
                    runAction(pendingAction);
                else
                    pendingAction = null;
            }
        } else if (left || right) {
            selectedIndex = (selectedIndex + (left ? -1 : 1) + actions.length) % actions.length;
        } else if (!event.isAutoRepeat) {
            const index = enter ? selectedIndex : actions.findIndex(action => action.key === event.key);
            if (index >= 0)
                choose(index);
        }
        event.accepted = true;
    }

    component ConfirmButton: Button {
        id: button
        property bool selected: false
        property color textColor: Theme.foreground

        implicitHeight: 40
        focusPolicy: Qt.NoFocus
        font.family: root.fontFamily
        background: Rectangle {
            radius: 8
            color: button.down ? Theme.surface("#3c393f") : button.hovered ? Theme.surface("#33343d") : Theme.surface("#282930")
            border.color: button.selected ? root.accent : Theme.surface("#3b3c45")
        }
        contentItem: Text {
            text: button.text
            font: button.font
            color: button.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    PanelWindow {
        screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        // Hyprland blurs behind this translucent surface.
        color: Theme.powerScrim
        WlrLayershell.namespace: "power-menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: surface
            anchors.fill: parent
            focus: true
            Keys.onPressed: event => root.handleKey(event)

            TapHandler {
                onTapped: point => {
                    if (!card.contains(card.mapFromItem(surface, point.position)))
                        Qt.quit();
                }
            }

            Item {
                id: card
                anchors.centerIn: parent
                width: Math.min(820, surface.width - 32)
                height: content.implicitHeight + 40

                ColumnLayout {
                    id: content
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
                    spacing: 16

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.pendingAction !== null
                        text: root.pendingAction ? root.pendingAction.label + "?" : ""
                        font { family: root.fontFamily; pixelSize: 24; bold: true }
                        color: Theme.foreground
                        style: Text.Outline
                        styleColor: Theme.background
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        uniformCellSizes: true
                        spacing: 18
                        visible: !root.pendingAction

                        Repeater {
                            model: root.actions

                            delegate: Button {
                                id: tile
                                required property var modelData
                                required property int index
                                readonly property bool selected: index === root.selectedIndex

                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                implicitHeight: 120
                                z: selected ? 1 : 0
                                padding: 0
                                text: modelData.label
                                focusPolicy: Qt.NoFocus
                                hoverEnabled: true
                                onHoveredChanged: if (hovered && !root.pendingAction) root.selectedIndex = index
                                onClicked: root.choose(index)
                                background: null

                                contentItem: Rectangle {
                                    radius: 12
                                    color: tile.down ? Theme.surface("#39434a") : tile.selected ? Theme.surface("#314348") : Theme.raised
                                    border.width: tile.selected ? 2 : 1
                                    border.color: tile.selected ? root.accent : Theme.surface("#3b3d46")
                                    scale: tile.down ? 1.06 : tile.selected ? 1.15 : 1
                                    transform: Translate {
                                        y: tile.selected ? -13 : 0
                                        Behavior on y { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                                    }
                                    Behavior on scale { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    ColumnLayout {
                                        anchors { fill: parent; margins: 8 }
                                        spacing: 5

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: tile.modelData.icon
                                            font { family: root.fontFamily; pixelSize: 30 }
                                            color: tile.selected ? root.accent : Theme.foreground
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.minimumWidth: 0
                                            horizontalAlignment: Text.AlignHCenter
                                            text: tile.text
                                            elide: Text.ElideRight
                                            font { family: root.fontFamily; pixelSize: 14; bold: true }
                                            color: Theme.foreground
                                        }

                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            implicitWidth: 26
                                            implicitHeight: 22
                                            radius: 5
                                            color: tile.selected ? root.accent : Theme.surface("#30323b")

                                            Text {
                                                anchors.centerIn: parent
                                                text: tile.modelData.hint
                                                font { family: root.fontFamily; pixelSize: 12; bold: true }
                                                color: tile.selected ? Theme.surface("#182225") : Theme.foreground
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(320, content.width)
                        visible: root.pendingAction !== null
                        spacing: 8

                        ConfirmButton {
                            Layout.fillWidth: true
                            text: "Cancel"
                            selected: !root.confirmSelected
                            onClicked: root.pendingAction = null
                        }

                        ConfirmButton {
                            Layout.fillWidth: true
                            text: root.pendingAction?.label ?? "Confirm"
                            textColor: Theme.errorText
                            selected: root.confirmSelected
                            onClicked: if (root.pendingAction) root.runAction(root.pendingAction)
                        }
                    }

                }
            }
        }
    }
}
