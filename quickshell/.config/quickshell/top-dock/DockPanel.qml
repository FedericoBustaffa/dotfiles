import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"

Scope {
    id: dock
    default property alias dockItems: contents.data
    property alias screen: panel.screen

    property var window: PanelWindow {
        id: panel
        anchors.top: true
        implicitWidth: contents.implicitWidth + 24
        implicitHeight: 36
        exclusionMode: ExclusionMode.Auto
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
