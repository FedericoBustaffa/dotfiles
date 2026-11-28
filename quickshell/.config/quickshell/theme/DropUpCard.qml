import QtQuick
import Quickshell
import "Palette.js" as Palette

Rectangle {
    id: card

    property bool presented: true
    property real slideOffset: 1
    property bool closing: false
    property var afterDismiss: null
    enabled: !closing

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    radius: 18
    bottomLeftRadius: 0
    bottomRightRadius: 0

    function scrim(color: color): color {
        return Qt.rgba(color.r, color.g, color.b, color.a * (1 - slideOffset));
    }

    function dismiss(after) {
        if (closing) return;
        afterDismiss = after;
        closing = true;
        slide.restart();
    }

    function dismissFromKeyboard(): void {
        dismiss(() => Palette.returnToPalette(Quickshell.env("QUICKSHELL_PALETTE_PARENT")));
    }

    // Keep the outline on the top and sides, but let the card meet the screen edge.
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: card.border.width; rightMargin: card.border.width }
        height: card.border.width
        color: card.color
    }

    transform: Translate { y: card.height * card.slideOffset }

    onPresentedChanged: if (presented && !closing) slide.restart()
    Component.onCompleted: if (presented) slide.start()

    NumberAnimation on slideOffset {
        id: slide
        running: false
        to: card.closing ? 1 : 0
        duration: 160
        easing.type: card.closing ? Easing.InCubic : Easing.OutCubic
        onFinished: {
            if (!card.closing) return;
            try { card.afterDismiss?.(); } finally { Qt.quit(); }
        }
    }
}
