pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "./theme"

Button {
    id: control
    required property var snapshot
    implicitWidth: 28
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: "System resources"
    onHoveredChanged: updatePopup()
    onClicked: openPopup()

    function openPopup() {
        closeDelay.stop();
        popup.visible = true;
        reveal.progress = 1;
    }

    function updatePopup() {
        if (hovered || popupHover.hovered) openPopup();
        else if (popup.visible) closeDelay.restart();
    }

    contentItem: DockReadout { icon: "󰍛"; iconColor: Theme.accent }
    background: Rectangle {
        radius: 7
        color: popup.visible ? Theme.selectedButton : "transparent"
    }

    Timer {
        id: closeDelay
        interval: 250
        onTriggered: reveal.progress = 0
    }

    PopupWindow {
        id: popup
        visible: false
        anchor.item: control
        anchor.rect.y: control.height + 6
        anchor.rect.width: control.width
        anchor.edges: Qt.BottomEdge
        anchor.gravity: Qt.BottomEdge
        implicitWidth: 290
        implicitHeight: metrics.implicitHeight + 28
        color: "transparent"

        HoverHandler {
            id: popupHover
            onHoveredChanged: control.updatePopup()
        }

        Rectangle {
            id: reveal
            property real progress: 0
            width: parent.width
            height: Math.round(popup.implicitHeight * progress)
            clip: true
            opacity: progress
            radius: 14
            color: Theme.background
            border.color: Theme.outline

            Behavior on progress {
                NumberAnimation {
                    duration: 185
                    easing.type: Easing.OutCubic
                    onRunningChanged: if (!running && reveal.progress === 0) popup.visible = false
                }
            }

            ColumnLayout {
                id: metrics
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
                spacing: 12

                DockLabel { text: "System resources"; font.bold: true; font.pixelSize: Theme.subtitleFontSize }
                Metric { label: "CPU"; glyph: ""; value: control.snapshot.cpu; tint: Theme.dockIcons.cpu; gauge: true }
                Metric { label: "Memory"; glyph: ""; value: control.snapshot.memory; tint: Theme.dockIcons.memory; gauge: true }
                Metric { label: "Root disk"; glyph: ""; value: control.snapshot.disk; tint: Theme.dockIcons.disk; gauge: true }
                Metric { label: "CPU temperature"; glyph: ""; value: control.snapshot.temp; tint: Theme.dockIcons.temperature }
                Metric { label: "Battery"; glyph: "󰁹"; value: control.snapshot.battery; tint: Theme.dockIcons.battery; gauge: true; visible: !!value }
            }
        }
    }

    component Metric: ColumnLayout {
        id: metric
        required property string label
        required property string glyph
        required property color tint
        property var value
        property bool gauge: false
        Layout.fillWidth: true
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            DockLabel { text: metric.glyph; color: metric.tint; Layout.preferredWidth: 18 }
            DockLabel { text: metric.label; Layout.fillWidth: true }
            DockLabel { text: metric.value || "—"; color: Theme.muted }
        }
        Rectangle {
            visible: metric.gauge
            Layout.fillWidth: true
            implicitHeight: 5
            radius: 3
            color: Theme.outline
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, (parseFloat(metric.value) || 0) / 100))
                height: parent.height
                radius: 3
                color: metric.tint
                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }
        }
    }
}
