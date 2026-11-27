import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"

Scope {
    id: dock
    default property alias dockItems: contents.data
    property alias screen: panel.screen
    property string position: "center"

    property var window: PanelWindow {
        id: panel
        anchors.top: true
        anchors.left: dock.position === "left"
        anchors.right: dock.position === "right"
        margins.left: anchors.left ? 8 : 0
        margins.right: anchors.right ? 8 : 0
        implicitWidth: contents.implicitWidth + 24
        implicitHeight: 36
        // Only the centered dock reserves top-edge space for tiled windows.
        exclusionMode: dock.position === "center" ? ExclusionMode.Auto : ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.namespace: "top-dock"
        WlrLayershell.layer: WlrLayer.Top

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            bottomLeftRadius: 14
            bottomRightRadius: 14

            RowLayout {
                id: contents
                anchors.centerIn: parent
                spacing: Theme.dockSpacing
            }
        }
    }
}
