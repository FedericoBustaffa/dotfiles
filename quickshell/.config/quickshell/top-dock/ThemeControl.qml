pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import "./theme"

Button {
    id: control
    implicitWidth: 26
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: "Change widget theme"
    onClicked: popup.visible = !popup.visible

    contentItem: DockLabel {
        text: "󰏘"
        horizontalAlignment: Text.AlignHCenter
    }
    background: Rectangle {
        radius: 7
        color: control.hovered || popup.visible ? Theme.outline : "transparent"
    }

    Connections {
        target: Theme
        function onCurrentChanged() { popup.visible = false; }
    }

    PopupWindow {
        id: popup
        visible: false
        anchor.item: control
        anchor.edges: Qt.BottomEdge
        anchor.gravity: Qt.BottomEdge
        implicitWidth: 150
        implicitHeight: choices.implicitHeight + 16
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.background
            border.color: Theme.outline

            Column {
                id: choices
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                spacing: 4

                Repeater {
                    model: Theme.choices
                    Button {
                        id: choice
                        required property var modelData
                        readonly property bool selected: Theme.current === modelData.id
                        width: choices.width
                        height: 32
                        hoverEnabled: true
                        enabled: !Theme.saving
                        text: modelData.label
                        Accessible.name: text + (selected ? " (active)" : "")
                        onClicked: {
                            if (selected) popup.visible = false;
                            else Theme.select(modelData.id);
                        }
                        contentItem: DockLabel {
                            text: (choice.selected ? "✓  " : "    ") + choice.text
                            color: choice.selected ? Theme.accent : Theme.foreground
                        }
                        background: Rectangle {
                            radius: 7
                            color: choice.hovered ? Theme.outline : choice.selected ? Theme.raised : "transparent"
                        }
                    }
                }
                DockLabel { visible: !!Theme.error; text: Theme.error; color: Theme.errorText }
            }
        }
    }
}
