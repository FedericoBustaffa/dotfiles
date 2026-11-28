pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "./theme"

Button {
    id: control
    required property var profiles
    required property string activeProfile
    property string error: ""
    property bool busy: false
    property bool yieldDrawer: false
    readonly property real progress: reveal.progress
    signal profileRequested(string profile)

    visible: profiles.length > 0
    implicitWidth: 26
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.name: "Power profile: " + labelFor(activeProfile)
    // Clicking the dock icon only opens the menu; it never changes the profile.
    onClicked: reveal.open()

    HoverReveal {
        id: reveal
        triggerHovered: control.hovered
        blocked: !control.visible || control.yieldDrawer
    }

    function labelFor(profile: string): string {
        return profile === "power-saver" ? "Power Saver" : profile === "performance" ? "Performance" : "Balanced";
    }

    function iconFor(profile: string): string {
        return profile === "power-saver" ? "" : profile === "performance" ? "" : "";
    }

    background: Rectangle {
        radius: 7
        color: control.hovered || control.progress > 0 ? Theme.dockHover : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    contentItem: Item {
        CenteredGlyph {
            text: control.iconFor(control.activeProfile)
            color: Theme.dockGlyph
        }
    }

    readonly property Component drawer: Rectangle {
        id: panel
        readonly property int rowHeight: 34
        readonly property int rowGap: 6
        readonly property int selectedIndex: control.profiles.indexOf(control.activeProfile)
        readonly property int expandedHeight: 18 + control.profiles.length * rowHeight
            + Math.max(0, control.profiles.length - 1) * rowGap
        implicitWidth: 60
        implicitHeight: Math.round(expandedHeight * control.progress)
        visible: height > 0
        clip: true
        color: Theme.background
        bottomLeftRadius: 16
        bottomRightRadius: 16
        Component.onDestruction: reveal.drawerHovered = false
        HoverHandler { onHoveredChanged: reveal.drawerHovered = hovered }

        SelectionOutline {
            x: 6
            y: 9 + Math.max(0, panel.selectedIndex) * (panel.rowHeight + panel.rowGap)
            width: panel.width - 12
            height: panel.rowHeight
            visible: panel.selectedIndex >= 0
            radius: 8
            color: Theme.selectedButton
            borderColor: Theme.accent
            Behavior on y { NumberAnimation { id: selectionSlide; duration: 230; easing.type: Easing.OutCubic } }
        }

        Column {
            id: options
            z: 1
            spacing: panel.rowGap
            x: 6
            y: 9
            width: panel.width - 12
            Repeater {
                model: control.profiles
                delegate: Button {
                    id: option
                    required property string modelData
                    readonly property bool selected: modelData === control.activeProfile
                    width: options.width
                    height: panel.rowHeight
                    padding: 0
                    focusPolicy: Qt.NoFocus
                    hoverEnabled: true
                    Accessible.name: control.labelFor(modelData) + (selected ? ", active" : "")
                    Accessible.description: control.error
                    onClicked: if (!selected && !control.busy) control.profileRequested(modelData)
                    background: Rectangle {
                        height: option.height
                        radius: 8
                        z: 0
                        visible: !option.selected && !selectionSlide.running
                        color: option.down ? Theme.selectedButton : option.hovered ? Theme.dockHover : Theme.background
                        // Fade the background, never the glyph above it.
                        opacity: option.hovered || option.down ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 135; easing.type: Easing.OutCubic } }
                    }
                    contentItem: Item {
                        z: 1
                        CenteredGlyph {
                            text: control.iconFor(option.modelData)
                            color: Theme.dockGlyph
                        }
                    }
                }
            }
        }

    }
}
