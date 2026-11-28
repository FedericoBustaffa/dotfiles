import QtQuick
import QtQuick.Controls
import "./theme"

Button {
    id: control
    property string glyph: ""
    property color glyphColor: Theme.foreground
    implicitWidth: Math.max(26, implicitContentWidth + 12)
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    background: Rectangle {
        radius: 7
        color: control.hovered ? Theme.outline : "transparent"
    }
    contentItem: DockReadout {
        icon: control.glyph
        iconColor: control.glyphColor
        text: control.text
    }
}
