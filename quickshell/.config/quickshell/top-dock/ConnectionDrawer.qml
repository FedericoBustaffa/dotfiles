pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "./theme"

Item {
    id: root
    property bool triggerHovered
    property bool blocked
    property var entries: []
    property int maximumWidth: 480
    property string message: "No saved connections"
    property string error: ""
    property color activeColor: Theme.accent
    property bool busy
    readonly property real progress: reveal.progress
    readonly property bool engaged: reveal.engaged
    signal connectRequested(var entry)

    HoverReveal {
        id: reveal
        triggerHovered: root.triggerHovered
        blocked: root.blocked
    }

    readonly property Component drawer: Rectangle {
        id: panel
        readonly property int expandedHeight: 20 + Math.min(6, Math.max(1, root.entries.length)) * 36 + (root.error ? 28 : 0)
        implicitWidth: Math.min(root.maximumWidth, Math.max(132, widestLabel + 56))
        readonly property real widestLabel: {
            const labels = root.entries.map(entry => (entry.active ? "✓  " : "") + entry.name);
            if (!labels.length) labels.push(root.message);
            if (root.error) labels.push(root.error);
            return Math.max(0, ...labels.map(label => metrics.advanceWidth(label)));
        }
        FontMetrics { id: metrics; font: emptyLabel.font }
        implicitHeight: Math.round(expandedHeight * root.progress)
        clip: true
        color: Theme.background
        bottomLeftRadius: 16
        bottomRightRadius: 16
        Component.onDestruction: reveal.drawerHovered = false
        HoverHandler { onHoveredChanged: reveal.drawerHovered = hovered }

        ListView {
            anchors.fill: parent
            anchors.margins: 10
            anchors.bottomMargin: root.error ? 38 : 10
            clip: true
            model: root.entries
            ScrollBar.vertical: ScrollBar {}
            delegate: Button {
                id: row
                required property var modelData
                width: ListView.view.width
                height: 36
                leftPadding: 18
                rightPadding: 18
                hoverEnabled: true
                enabled: !modelData.active && !root.busy && modelData.available !== false
                Accessible.name: modelData.name + (modelData.active ? ", connected" : "")
                onClicked: root.connectRequested(modelData)
                background: Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 8
                    color: row.modelData.active ? Theme.selectedButton : Theme.outline
                    opacity: row.modelData.active || row.hovered ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 140 } }
                }
                contentItem: DockLabel {
                    horizontalAlignment: Text.AlignHCenter
                    text: (row.modelData.active ? "✓  " : "") + row.modelData.name
                    color: row.modelData.active ? root.activeColor : row.enabled ? Theme.foreground : Theme.muted
                    elide: Text.ElideRight
                }
            }
        }
        DockLabel {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
            visible: !!root.error
            horizontalAlignment: Text.AlignHCenter
            text: root.error
            elide: Text.ElideRight
            color: Theme.errorText
        }
        DockLabel {
            id: emptyLabel
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.error ? -14 : 0
            width: parent.width - 20
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            visible: root.entries.length === 0
            text: root.message
            color: Theme.muted
        }
    }
}
