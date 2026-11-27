import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./theme"

Scope {
    id: dock
    default property alias dockItems: contents.data
    property alias screen: panel.screen
    property Component extension
    property Component sideExtension
    property Item sideAnchor
    readonly property int barHeight: 36

    property var window: PanelWindow {
        id: panel
        anchors.top: true
        implicitWidth: contents.implicitWidth + 24
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
                y: dock.barHeight
                width: details.width
                height: details.height > 0 ? details.item.expandedHeight : 0
            }
            Region {
                x: sideDetails.x
                y: dock.barHeight
                width: sideDetails.width
                height: sideDetails.height > 0 ? sideDetails.item.expandedHeight : 0
            }
        }

        Rectangle {
            id: header
            width: parent.width
            height: dock.barHeight
            color: Theme.background
            bottomLeftRadius: details.height > 0 ? 0 : 14
            bottomRightRadius: bottomLeftRadius

            RowLayout {
                id: contents
                anchors.centerIn: parent
                spacing: Theme.dockSpacing
            }
        }

        Loader {
            id: details
            anchors { top: header.bottom; left: parent.left; right: parent.right }
            sourceComponent: dock.extension
        }

        Loader {
            id: sideDetails
            anchors.top: header.bottom
            x: dock.sideAnchor ? Math.max(0, Math.min(header.width - width,
                contents.x + dock.sideAnchor.x + (dock.sideAnchor.width - width) / 2)) : 0
            sourceComponent: dock.sideExtension
        }
    }
}
