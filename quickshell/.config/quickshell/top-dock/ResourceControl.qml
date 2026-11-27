pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./theme"

Button {
    id: control
    required property var snapshot
    property bool drawerHovered: false
    property bool drawerObscured: false
    property real progress: 0
    implicitWidth: 28
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: "System resources"
    onHoveredChanged: updateDrawer()
    onDrawerObscuredChanged: updateDrawer()
    onClicked: openDrawer()

    function openDrawer() {
        if (drawerObscured) return;
        closeDelay.stop();
        animateDrawer(1);
    }

    function animateDrawer(targetProgress: real) {
        if (reveal.running ? reveal.to === targetProgress : progress === targetProgress) return;
        reveal.stop();
        reveal.from = progress;
        reveal.to = targetProgress;
        reveal.start();
    }

    function updateDrawer() {
        if (drawerObscured) {
            // Start the reveal only after the volume drawer has finished closing.
            closeDelay.stop();
            reveal.stop();
            progress = 0;
        } else if (hovered || drawerHovered) {
            openDrawer();
        } else if (progress > 0) {
            closeDelay.restart();
        }
    }

    contentItem: DockReadout { icon: "󰓅"; iconColor: Theme.accent }
    background: Rectangle {
        radius: 7
        color: control.progress > 0 ? Theme.selectedButton : "transparent"
    }

    Timer {
        id: closeDelay
        interval: 140
        onTriggered: control.animateDrawer(0)
    }

    NumberAnimation {
        id: reveal
        target: control
        property: "progress"
        duration: 185
        easing.type: Easing.OutCubic
    }

    readonly property Component drawer: Rectangle {
        readonly property int expandedHeight: metrics.implicitHeight + 28
        implicitHeight: control.drawerObscured ? 0 : Math.round(expandedHeight * control.progress)
        visible: height > 0
        clip: true
        bottomLeftRadius: 14
        bottomRightRadius: 14
        color: Theme.background

        HoverHandler {
            onHoveredChanged: {
                control.drawerHovered = hovered;
                control.updateDrawer();
            }
        }

        ColumnLayout {
            id: metrics
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            spacing: 12

            DockLabel { text: "System resources"; font.bold: true; font.pixelSize: Theme.subtitleFontSize }
            RowLayout {
                Layout.fillWidth: true
                uniformCellSizes: true
                spacing: 12

                ResourceGauge {
                    label: "CPU"; glyph: ""; tint: Theme.dockIcons.cpu
                    value: control.snapshot.cpu ?? ""
                    detail: control.snapshot.temp || "—"
                    detailIcon: ""
                    detailHint: "CPU temperature"
                }
                ResourceGauge {
                    label: "RAM"; glyph: ""; tint: Theme.dockIcons.memory
                    value: control.snapshot.memory ?? ""
                    detail: control.snapshot.memoryUsed || "—"
                }
                ResourceGauge {
                    label: "Root disk"; glyph: ""; tint: Theme.dockIcons.disk
                    value: control.snapshot.disk ?? ""
                    detail: control.snapshot.diskUsed || "—"
                }
            }
        }
    }
}
