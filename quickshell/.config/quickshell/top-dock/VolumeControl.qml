pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./theme"

Button {
    id: button
    required property var audio
    readonly property real level: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false
    property bool adjusting: false
    property bool yieldDrawer: false
    readonly property real progress: reveal.progress

    visible: audio != null
    text: muted ? "" : Math.round(level * 100) + "%"
    Accessible.name: "Volume. Click to toggle mute."
    implicitWidth: 60
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    onClicked: if (audio) audio.muted = !audio.muted
    HoverReveal {
        id: reveal
        triggerHovered: button.hovered
        heldOpen: button.adjusting
        blocked: !button.visible || (button.yieldDrawer && !button.adjusting)
        closeDelay: 140
        duration: 185
    }

    background: Rectangle {
        radius: 7
        color: button.progress > 0 ? Theme.selectedButton : "transparent"
    }
    contentItem: DockReadout {
        icon: button.muted ? "󰝟" : "󰕾"
        iconColor: button.muted ? Theme.muted : Theme.dockIcons.volume
        text: button.text
    }

    readonly property Component drawer: Rectangle {
        id: details
        readonly property int expandedHeight: 152
        implicitWidth: 54
        implicitHeight: Math.round(expandedHeight * button.progress)
        visible: height > 0
        clip: true
        bottomLeftRadius: 16
        bottomRightRadius: 16
        color: Theme.background

        Component.onDestruction: reveal.drawerHovered = false
        HoverHandler { onHoveredChanged: reveal.drawerHovered = hovered }

        ColumnLayout {
            x: 8
            y: 8
            width: details.width - 16
            height: details.expandedHeight - 16
            spacing: 6

            Slider {
                id: slider
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                implicitWidth: 24
                padding: 6
                orientation: Qt.Vertical
                from: 0
                to: 1
                value: Math.min(button.level, 1)
                focusPolicy: Qt.NoFocus
                Accessible.name: "Output volume"
                onPressedChanged: {
                    button.adjusting = pressed;
                }
                onMoved: if (button.audio) {
                    button.audio.volume = value;
                    if (value > 0 && button.audio.muted)
                        button.audio.muted = false;
                }
                background: Rectangle {
                    x: (slider.width - width) / 2
                    y: slider.topPadding
                    width: 5
                    height: slider.availableHeight
                    radius: 3
                    color: Theme.outline
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: slider.position * parent.height
                        radius: 3
                        color: Theme.accent
                    }
                }
                handle: Rectangle {
                    x: (slider.width - width) / 2
                    y: slider.topPadding + slider.visualPosition * (slider.availableHeight - height)
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.accent
                }
            }

            DockLabel {
                Layout.alignment: Qt.AlignHCenter
                text: button.muted ? "󰝟" : Math.round(button.level * 100) + "%"
                font.pixelSize: Theme.bodyFontSize
            }
        }
    }
}
