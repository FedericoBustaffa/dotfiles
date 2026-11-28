pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import "./theme"
import "./theme/Palette.js" as Palette

Scope {
    id: center
    readonly property var history: server.trackedNotifications.values.filter(item => !item.transient).slice().reverse()
    readonly property int count: history.length
    property bool dnd: false
    property Notification toast: null
    property var toastScreen: null
    property var centerScreen: null
    property bool opened: false
    property string paletteQuery: ""
    onOpenedChanged: {
        if (opened) overlay.returnQuery = "";
        else paletteQuery = "";
    }

    function focusedScreen() {
        return Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0] ?? null;
    }

    function hideToast() {
        const item = toast;
        toast = null;
        toastTimer.stop();
        if (item?.transient) item.expire();
    }

    function toggle(screen) {
        if (!screen) screen = focusedScreen();
        opened = !(opened && centerScreen === screen) && !!screen;
        centerScreen = screen;
        if (opened) hideToast();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        actionsSupported: true
        imageSupported: true
        onNotification: item => {
            item.tracked = true;
            if (item.lastGeneration) return;
            if (!item.transient && center.history.length > 100) center.history[100].dismiss();
            if (center.opened || (center.dnd && item.urgency !== NotificationUrgency.Critical)) {
                if (item.transient) item.expire();
                return;
            }
            if (center.toast !== item) center.hideToast();
            center.toastScreen = center.focusedScreen();
            center.toast = item;
            toastTimer.interval = item.expireTimeout > 0 ? Math.min(item.expireTimeout, 60000) : 5000;
            toastTimer.start();
        }
    }

    Connections {
        target: center.toast
        function onClosed() { center.toast = null; toastTimer.stop(); }
    }

    Timer { id: toastTimer; onTriggered: center.hideToast() }

    IpcHandler {
        target: "notifications"
        function toggle(): void { center.toggle(null); }
        function openFromPalette(query: string): void {
            center.centerScreen = center.focusedScreen();
            center.paletteQuery = query;
            center.opened = !!center.centerScreen;
            if (center.opened) center.hideToast();
        }
    }

    component ActionButton: Button {
        id: action
        property bool accented: false
        hoverEnabled: true
        focusPolicy: Qt.NoFocus
        padding: 8
        contentItem: Text {
            text: action.text
            textFormat: Text.PlainText
            color: Theme.menuText(action.accented)
            font.pixelSize: Theme.menuBodyFontSize
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        background: Rectangle {
            radius: 7
            color: action.hovered ? Theme.outline : Theme.button
        }
    }

    component NotificationCard: Rectangle {
        id: card
        required property Notification entry
        implicitHeight: content.implicitHeight + 20
        radius: 10
        color: Theme.raised
        border.color: entry?.urgency === NotificationUrgency.Critical ? Theme.errorText : Theme.outline

        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: card.entry?.appName || "Notification"
                    textFormat: Text.PlainText
                    color: Theme.accent
                    font.pixelSize: Theme.bodyFontSize
                    elide: Text.ElideRight
                }
                ActionButton {
                    text: "×"
                    Accessible.name: "Dismiss notification"
                    onClicked: card.entry?.dismiss()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Image {
                    visible: status === Image.Ready
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    fillMode: Image.PreserveAspectFit
                    source: card.entry?.image || (card.entry?.appIcon ? Quickshell.iconPath(card.entry.appIcon, true) : "")
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: card.entry?.summary ?? ""
                        textFormat: Text.PlainText
                        font { pixelSize: Theme.subtitleFontSize; bold: true }
                        color: Theme.foreground
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: card.entry?.body ?? ""
                        textFormat: Text.PlainText
                        font.pixelSize: Theme.bodyFontSize
                        color: Theme.muted
                        wrapMode: Text.Wrap
                        maximumLineCount: 5
                        elide: Text.ElideRight
                    }
                }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 5
                visible: (card.entry?.actions.length ?? 0) > 0
                Repeater {
                    model: card.entry?.actions ?? []
                    ActionButton {
                        required property var modelData
                        text: modelData.text || (modelData.identifier === "default" ? "Open" : "Action")
                        width: Math.min(implicitWidth, content.width)
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }

    PanelWindow {
        screen: center.toastScreen
        visible: !!center.toast && !!center.toastScreen && !center.opened
        anchors { top: true; right: true }
        margins { top: 44; right: 12 }
        implicitWidth: 390
        implicitHeight: toastCard.implicitHeight
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.namespace: "notification-toast"
        WlrLayershell.layer: WlrLayer.Overlay

        NotificationCard {
            id: toastCard
            anchors.fill: parent
            entry: center.toast
            HoverHandler {
                onHoveredChanged: {
                    if (hovered) toastTimer.stop();
                    else if (center.toast) toastTimer.restart();
                }
            }
        }
    }

    PanelWindow {
        screen: center.centerScreen
        visible: !!center.centerScreen && (center.opened || drawer.revealProgress > 0)
        onVisibleChanged: {
            if (visible || !overlay.returnQuery) return;
            Palette.returnToPalette(overlay.returnQuery);
            overlay.returnQuery = "";
        }
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.namespace: "notification-center"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: overlay
            property string returnQuery: ""
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: {
                if (!center.opened) return;
                returnQuery = center.paletteQuery;
                center.opened = false;
            }
            TapHandler {
                onTapped: point => {
                    if (!drawer.contains(drawer.mapFromItem(overlay, point.position))) center.opened = false;
                }
            }
            Item {
                id: barGeometry
                width: parent.width
                height: Theme.dockHeight
            }

            Rectangle {
                anchors { top: barGeometry.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
                color: Theme.managerScrim
                opacity: drawer.revealProgress
            }

            DrawerJoin { drawer: drawer; bar: barGeometry }

            Item {
                id: drawer
                readonly property real expandedHeight: Math.max(0, Math.min(520, overlay.height - Theme.dockHeight - 20))
                property real revealProgress: center.opened ? 1 : 0
                enabled: center.opened
                anchors { top: barGeometry.bottom; horizontalCenter: parent.horizontalCenter }
                width: Math.min(440, overlay.width - 24)
                height: expandedHeight * revealProgress
                clip: true

                Behavior on revealProgress {
                    NumberAnimation {
                        duration: 160
                        easing.type: center.opened ? Easing.OutCubic : Easing.InCubic
                    }
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: drawer.expandedHeight
                    color: Theme.background
                    bottomLeftRadius: 16
                    bottomRightRadius: 16

                    RowLayout {
                        id: header
                        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
                        Text {
                            Layout.fillWidth: true
                            text: "Notifications"
                            color: Theme.foreground
                            font { pixelSize: Theme.menuTitleFontSize; bold: true }
                        }
                        ActionButton {
                            text: center.dnd ? "DND on" : "DND off"
                            Accessible.name: "Do Not Disturb"
                            accented: center.dnd
                            onClicked: center.dnd = !center.dnd
                        }
                        ActionButton {
                            text: "Clear all"
                            enabled: center.count > 0
                            onClicked: center.history.slice().forEach(item => item.dismiss())
                        }
                        ActionButton {
                            text: "×"
                            Accessible.name: "Close notification center"
                            onClicked: center.opened = false
                        }
                    }

                    ListView {
                        id: list
                        anchors { top: header.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 12 }
                        clip: true
                        spacing: 6
                        model: center.history
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        delegate: NotificationCard {
                            required property Notification modelData
                            entry: modelData
                            width: list.width - 8
                        }
                    }
                    Text {
                        anchors.centerIn: list
                        visible: center.count === 0
                        text: "No notifications"
                        color: Theme.muted
                        font.pixelSize: Theme.bodyFontSize
                    }
                }
            }
        }
    }
}
