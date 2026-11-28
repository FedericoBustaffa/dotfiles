import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"

Scope {
    id: dock
    property alias leftItems: leftControls.data
    property alias centerItems: centerControls.data
    default property alias rightItems: rightControls.data
    property alias screen: panel.screen
    property Component extension
    property Component sideExtension
    property Item sideAnchor
    readonly property int barHeight: 36

    property var window: PanelWindow {
        id: panel
        anchors { top: true; left: true; right: true }
        // Animate the drawers inside a fixed layer so hover doesn't depend on Wayland resizes.
        implicitHeight: dock.barHeight + Math.max(details.item?.expandedHeight ?? 0, sideDetails.item?.expandedHeight ?? 0)
        // Only the header reserves workspace space; the drawer overlays it.
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: dock.barHeight
        color: "transparent"
        WlrLayershell.namespace: "top-dock"
        WlrLayershell.layer: WlrLayer.Top
        // Keep the transparent space beside the narrow drawer click-through.
        mask: Region {
            item: header
            Region {
                x: details.x
                y: dock.barHeight
                width: details.width
                height: details.height
            }
            Region {
                x: sideDetails.x
                y: dock.barHeight
                width: sideDetails.width
                height: sideDetails.height
            }
        }

        Rectangle {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: dock.barHeight
            color: Theme.background

            RowLayout {
                id: centerControls
                anchors.centerIn: parent
                spacing: Theme.dockSpacing
            }
            RowLayout {
                id: leftControls
                anchors.right: centerControls.left
                anchors.rightMargin: Theme.dockSpacing
                anchors.verticalCenter: centerControls.verticalCenter
                spacing: Theme.dockSpacing
            }
            RowLayout {
                id: rightControls
                anchors.left: centerControls.right
                anchors.leftMargin: Theme.dockSpacing
                anchors.verticalCenter: centerControls.verticalCenter
                spacing: Theme.dockSpacing
            }
        }

        Loader {
            id: details
            anchors { top: header.bottom; horizontalCenter: parent.horizontalCenter }
            width: Math.min(parent.width, item?.implicitWidth ?? 0)
            sourceComponent: dock.extension
        }

        DrawerJoin { drawer: details; bar: header }
        DrawerJoin { drawer: sideDetails; bar: header }

        Loader {
            id: sideDetails
            anchors.top: header.bottom
            x: dock.sideAnchor ? Math.max(0, Math.min(header.width - width,
                rightControls.x + dock.sideAnchor.x + (dock.sideAnchor.width - width) / 2)) : 0
            sourceComponent: dock.sideExtension
        }
    }
}
