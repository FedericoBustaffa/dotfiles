pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./theme"

Button {
    id: control
    required property var snapshot
    property bool drawerObscured: false
    readonly property real progress: reveal.progress
    implicitWidth: 28
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: "System resources"
    onClicked: reveal.open()

    HoverReveal {
        id: reveal
        triggerHovered: control.hovered
        blocked: control.drawerObscured
        immediateClose: true
        closeDelay: 140
        duration: 185
    }

    contentItem: DockReadout { icon: "󰓅"; iconColor: Theme.dockGlyph }
    background: Rectangle {
        radius: 7
        color: control.hovered || control.progress > 0 ? Theme.dockHover : "transparent"
    }

    readonly property Component drawer: Rectangle {
        implicitWidth: 476
        readonly property int expandedHeight: metrics.implicitHeight + 28
        implicitHeight: control.drawerObscured ? 0 : Math.round(expandedHeight * control.progress)
        visible: height > 0
        clip: true
        bottomLeftRadius: 16
        bottomRightRadius: 16
        color: Theme.background

        HoverHandler { onHoveredChanged: reveal.drawerHovered = hovered }

        ColumnLayout {
            id: metrics
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            spacing: 8

            DockLabel { text: "System resources"; font.bold: true; font.pixelSize: Theme.subtitleFontSize }
            RowLayout {
                Layout.fillWidth: true
                uniformCellSizes: true
                spacing: 12

                ResourceGauge {
                    title: "CPU"
                    secondReadoutOnArc: true
                    metrics: [
                        { label: "CPU", glyph: "", tint: Theme.resourceTints.cpu,
                            value: control.snapshot.cpu, hint: "CPU usage" },
                        { label: "Temp", glyph: "", tint: Theme.resourceTints.cpu,
                            value: control.snapshot.temp, hint: "CPU temperature · 0–100°C scale" }
                    ]
                }
                ResourceGauge {
                    title: "Memory"
                    secondReadoutOnArc: true
                    metrics: [
                        { label: "RAM", glyph: "", tint: Theme.resourceTints.memory,
                            value: control.snapshot.memory, display: control.snapshot.memoryUsed, hint: "RAM usage" },
                        { label: "Disk", glyph: "", tint: Theme.resourceTints.disk,
                            value: control.snapshot.disk, display: control.snapshot.diskUsed, hint: "Root disk usage" }
                    ]
                }
            }
        }
    }
}
