import QtQuick
import QtQuick.Controls
import "./theme"

Text {
    id: label
    property string hint: ""
    font.family: "JetBrainsMono Nerd Font"
    HoverHandler { id: hover; enabled: label.hint !== "" }
    ToolTip.visible: hover.hovered
    ToolTip.text: hint
    ToolTip.delay: 350
    color: Theme.foreground
    font.pixelSize: 12
    verticalAlignment: Text.AlignVCenter
}
