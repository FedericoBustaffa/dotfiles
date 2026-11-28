import QtQuick
import QtQuick.Controls
import "./theme"

Text {
    property string hint: ""
    Accessible.description: hint
    font.family: "JetBrainsMono Nerd Font"
    textFormat: Text.PlainText
    color: Theme.foreground
    font.pixelSize: Theme.bodyFontSize
    verticalAlignment: Text.AlignVCenter
}
