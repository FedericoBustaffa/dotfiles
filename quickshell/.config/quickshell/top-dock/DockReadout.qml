pragma ComponentBehavior: Bound

import QtQuick
import "./theme"

Item {
    id: readout
    property string icon: ""
    property color iconColor: Theme.foreground
    property string text: ""
    property color textColor: Theme.foreground
    property string hint: ""
    property bool highlightOnHover: false
    property int iconSize: Theme.bodyFontSize
    Accessible.description: hint
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    HoverHandler { id: pointer; enabled: readout.highlightOnHover }

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: pointer.hovered ? Theme.dockHover : "transparent"
        visible: readout.highlightOnHover
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 7

        DockLabel { visible: !!readout.icon; text: readout.icon; color: readout.iconColor; font.pixelSize: readout.iconSize }
        DockLabel { visible: !!readout.text; text: readout.text; color: readout.textColor }
    }

}
