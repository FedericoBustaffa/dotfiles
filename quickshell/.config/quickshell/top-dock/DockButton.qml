import QtQuick
import QtQuick.Controls
import "./theme"

Button {
    id: control
    property string glyph: ""
    property color textColor: Theme.foreground
    property bool drawerOpen: false
    implicitWidth: Math.max(26, implicitContentWidth + 12)
    implicitHeight: 24
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    background: Rectangle {
        radius: 7
        color: control.hovered || control.drawerOpen ? Theme.dockHover : "transparent"
    }
    contentItem: DockReadout {
        icon: control.glyph
        iconColor: Theme.dockGlyph
        text: control.text
        textColor: control.textColor
    }
}
