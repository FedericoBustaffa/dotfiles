pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "./theme"

Item {
    id: readout
    property string icon: ""
    property color iconColor: Theme.foreground
    property string text: ""
    property string hint: ""
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 7

        DockLabel { visible: !!readout.icon; text: readout.icon; color: readout.iconColor }
        DockLabel { visible: !!readout.text; text: readout.text }
    }

    HoverHandler { id: hover; enabled: !!readout.hint }
    ToolTip.visible: hover.hovered
    ToolTip.text: hint
    ToolTip.delay: 350
}
