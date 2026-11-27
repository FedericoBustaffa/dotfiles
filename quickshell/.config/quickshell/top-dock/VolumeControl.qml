import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "./theme"

Button {
    id: button
    required property var audio
    readonly property real level: audio?.volume ?? 0
    readonly property bool muted: audio?.muted ?? false
    readonly property bool adjusting: slider.pressed

    visible: audio != null
    text: muted ? "󰝟" : "󰕾 " + Math.round(level * 100) + "%"
    Accessible.name: "Volume. Click to toggle mute."
    implicitWidth: Math.max(26, implicitContentWidth + 12)
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    onClicked: if (audio) audio.muted = !audio.muted
    onHoveredChanged: updatePopup()
    onVisibleChanged: if (!visible) popup.visible = false

    function updatePopup() {
        if (visible && (hovered || popupHover.hovered || slider.pressed)) {
            closeDelay.stop();
            popup.visible = true;
        } else if (popup.visible) {
            closeDelay.restart();
        }
    }

    background: Rectangle {
        radius: 7
        color: button.hovered ? Theme.outline : "transparent"
    }
    contentItem: DockLabel {
        text: button.text
        horizontalAlignment: Text.AlignHCenter
    }

    Timer {
        id: closeDelay
        interval: 300
        onTriggered: popup.visible = false
    }

    PopupWindow {
        id: popup
        visible: false
        anchor.item: button
        anchor.edges: Qt.BottomEdge
        anchor.gravity: Qt.BottomEdge
        implicitWidth: 54
        implicitHeight: 152
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.background
            border.color: Theme.outline

            HoverHandler {
                id: popupHover
                onHoveredChanged: button.updatePopup()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
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
                    onPressedChanged: button.updatePopup()
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
                }
            }
        }
    }
}
