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
    font.pixelSize: Theme.bodyFontSize
    verticalAlignment: Text.AlignVCenter
}
