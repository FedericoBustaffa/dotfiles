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
    property bool drawerHovered: false
    property bool yieldDrawer: false
    property real progress: 0

    visible: audio != null
    text: muted ? "" : Math.round(level * 100) + "%"
    Accessible.name: "Volume. Click to toggle mute."
    implicitWidth: Math.max(60, implicitContentWidth + 12)
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    onClicked: if (audio) audio.muted = !audio.muted
    onHoveredChanged: updateDrawer()
    onYieldDrawerChanged: updateDrawer()
    onVisibleChanged: if (!visible) {
        closeDelay.stop();
        progress = 0;
    }

    function updateDrawer() {
        if (yieldDrawer && !adjusting) {
            closeDelay.stop();
            progress = 0;
        } else if (visible && (hovered || drawerHovered || adjusting)) {
            closeDelay.stop();
            progress = 1;
        } else if (progress > 0) {
            closeDelay.restart();
        }
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

    Timer {
        id: closeDelay
        interval: 140
        onTriggered: button.progress = 0
    }

    Behavior on progress {
        NumberAnimation { duration: 185; easing.type: Easing.OutCubic }
    }

    readonly property Component drawer: Rectangle {
        id: details
        readonly property int expandedHeight: 152
        implicitWidth: 54
        implicitHeight: Math.round(expandedHeight * button.progress)
        visible: height > 0
        clip: true
        bottomLeftRadius: 12
        bottomRightRadius: 12
        color: Theme.background

        HoverHandler {
            onHoveredChanged: {
                button.drawerHovered = hovered;
                button.updateDrawer();
            }
        }

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
                    button.updateDrawer();
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
