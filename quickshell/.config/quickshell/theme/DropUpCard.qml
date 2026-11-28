import QtQuick
import Quickshell

Rectangle {
    id: card

    // Bind to the window's visibility when the same overlay can open repeatedly.
    property bool presented: true
    property real slideOffset: 1

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    radius: 18
    bottomLeftRadius: 0
    bottomRightRadius: 0

    function returnToPalette(query: string): void {
        if (!query.startsWith(">")) return;
        Quickshell.execDetached(["env", "QUICKSHELL_PALETTE_QUERY=" + query,
            "quickshell", "-n", "-p", Quickshell.shellDir + "/../app-launcher"]);
    }

    function dismissFromKeyboard(): void {
        returnToPalette(Quickshell.env("QUICKSHELL_PALETTE_PARENT"));
        Qt.quit();
    }

    // Keep the outline on the top and sides, but let the card meet the screen edge.
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: card.border.width; rightMargin: card.border.width }
        height: card.border.width
        color: card.color
    }

    transform: Translate { y: card.height * card.slideOffset }

    onPresentedChanged: {
        if (presented) rise.restart();
        else rise.stop();
    }
    Component.onCompleted: if (presented) rise.start()

    NumberAnimation {
        id: rise
        target: card
        property: "slideOffset"
        from: 1
        to: 0
        duration: 235
        easing.type: Easing.OutCubic
    }
}
