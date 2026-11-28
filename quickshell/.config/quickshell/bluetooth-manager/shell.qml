pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property color accent: Theme.accent
    readonly property color foreground: Theme.foreground
    readonly property color muted: Theme.muted
    readonly property var devices: (adapter?.devices.values ?? []).filter(device =>
        device.connected || device.paired || device.bonded || device.pairing || root.showNearby
    ).sort((a, b) => root.priority(a) - root.priority(b) || a.name.localeCompare(b.name))
    property var scanningAdapter: null
    property bool showNearby: false
    property string forgetAddress: ""

    function priority(device) {
        return device.connected ? 0 : device.paired || device.bonded ? 1 : 2;
    }

    function toggleScan() {
        if (scanningAdapter) {
            stopScan();
        } else if (adapter?.enabled && !adapter.discovering) {
            scanningAdapter = adapter;
            showNearby = true;
            adapter.discovering = true;
            scanTimeout.restart();
        }
    }

    function stopScan() {
        if (scanningAdapter?.discovering) scanningAdapter.discovering = false;
        scanningAdapter = null;
        scanTimeout.stop();
    }

    function dismiss() {
        stopScan();
        card.dismiss();
    }

    Timer { id: scanTimeout; interval: 30000; onTriggered: root.stopScan() }
    Timer { id: forgetTimeout; interval: 4000; onTriggered: root.forgetAddress = "" }

    component LabelText: Text {
        color: Theme.menuText()
        font.pixelSize: Theme.menuBodyFontSize
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
    }

    component ActionButton: Button {
        id: action
        property bool accented: false
        implicitHeight: 32
        padding: 8
        leftPadding: 12
        rightPadding: 12
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus
        Keys.onReturnPressed: action.clicked()
        Keys.onEnterPressed: action.clicked()
        contentItem: Text {
            text: action.text
            color: Theme.menuText()
            font.pixelSize: Theme.menuBodyFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 8
            color: !action.enabled ? Theme.disabled : action.hovered ? Theme.buttonHover : Theme.button
            border.color: action.visualFocus || (action.accented && action.enabled) ? Theme.accent : Theme.outline
            border.width: action.visualFocus ? 2 : 1
        }
    }

    PanelWindow {
        id: overlay
        screen: Quickshell.screens.find(screen => screen.name === Quickshell.env("BLUETOOTH_MANAGER_OUTPUT"))
            ?? Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: card.scrim(Theme.managerScrim)
        WlrLayershell.namespace: "bluetooth-manager"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: surface
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: { root.stopScan(); card.dismissFromKeyboard(); }

            TapHandler {
                onTapped: point => {
                    if (!card.contains(card.mapFromItem(surface, point.position))) root.dismiss();
                }
            }

            DropUpCard {
                id: card
                width: Math.min(520, surface.width - 32)
                height: Math.min(440, surface.height - 32)
                color: Theme.background
                border.color: Theme.outline

                ColumnLayout {
                    anchors { fill: parent; margins: 18 }
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        LabelText {
                            Layout.fillWidth: true
                            text: "Bluetooth"
                            font { pixelSize: Theme.menuTitleFontSize; bold: true }
                        }
                        ActionButton {
                            text: "Close"
                            Component.onCompleted: forceActiveFocus(Qt.TabFocusReason)
                            onClicked: root.dismiss()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        LabelText {
                            Layout.fillWidth: true
                            color: root.muted
                            elide: Text.ElideRight
                            text: root.adapter?.name ?? "No Bluetooth adapter"
                            font.pixelSize: Theme.menuSubtitleFontSize
                        }
                        Switch {
                            id: powerSwitch
                            text: "Bluetooth power"
                            Accessible.name: text
                            contentItem: Item {}
                            implicitWidth: implicitIndicatorWidth + leftPadding + rightPadding
                            checked: root.adapter?.enabled ?? false
                            enabled: !!root.adapter && root.adapter.state !== BluetoothAdapterState.Blocked
                                && root.adapter.state !== BluetoothAdapterState.Enabling
                                && root.adapter.state !== BluetoothAdapterState.Disabling
                            onToggled: {
                                if (!checked) {
                                    root.stopScan();
                                    root.showNearby = false;
                                }
                                if (root.adapter) root.adapter.enabled = checked;
                            }
                        }
                        ActionButton {
                            text: root.scanningAdapter ? "Stop scan" : root.adapter?.discovering ? "Scanning…" : "Scan"
                            accented: !root.adapter?.discovering
                            enabled: !!root.adapter?.enabled && (!root.adapter.discovering || !!root.scanningAdapter)
                            onClicked: root.toggleScan()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: deviceList
                            anchors.fill: parent
                            anchors.rightMargin: 8
                            clip: true
                            visible: root.adapter?.enabled ?? false
                            spacing: 6
                            model: root.devices
                            activeFocusOnTab: count > 0
                            keyNavigationEnabled: true
                            Keys.onReturnPressed: currentItem?.activate()
                            Keys.onEnterPressed: currentItem?.activate()
                            Keys.onSpacePressed: currentItem?.activate()
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                            delegate: Rectangle {
                                id: row
                                required property int index
                                required property var modelData
                                function activate() { if (primary.enabled) primary.clicked(); }
                                readonly property var device: modelData
                                readonly property bool saved: device.paired || device.bonded
                                readonly property bool busy: device.state === BluetoothDeviceState.Connecting
                                    || device.state === BluetoothDeviceState.Disconnecting
                                readonly property bool confirmForget: root.forgetAddress === device.address
                                width: deviceList.width - 8
                                height: 58
                                radius: 10
                                color: Theme.raised
                                border.width: 2
                                border.color: ListView.isCurrentItem && deviceList.activeFocus ? Theme.accent : "transparent"

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 10; rightMargin: 8 }
                                    spacing: 6

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        LabelText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            text: row.device.name || row.device.address
                                            color: Theme.menuText(row.device.connected)
                                            font.bold: row.device.connected
                                        }
                                        LabelText {
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            color: row.device.connected ? root.accent : root.muted
                                            text: (row.device.pairing ? "Pairing…" : row.busy ? BluetoothDeviceState.toString(row.device.state)
                                                : row.device.connected ? "Connected" : row.saved ? "Paired" : "Nearby")
                                                + (row.device.batteryAvailable ? "  ·  " + Math.round(row.device.battery * 100) + "% battery" : "")
                                        }
                                    }

                                    ActionButton {
                                        id: primary
                                        onActiveFocusChanged: if (activeFocus) deviceList.currentIndex = row.index
                                        text: row.device.pairing ? "Cancel" : row.device.connected ? "Disconnect" : row.saved ? "Connect" : "Pair"
                                        enabled: !row.busy
                                        accented: !row.device.connected && !row.device.pairing
                                        onClicked: {
                                            if (row.device.pairing) row.device.cancelPair();
                                            else if (row.device.connected) row.device.disconnect();
                                            else if (row.saved) row.device.connect();
                                            else row.device.pair();
                                        }
                                    }
                                    ActionButton {
                                        visible: row.saved
                                        onActiveFocusChanged: if (activeFocus) deviceList.currentIndex = row.index
                                        enabled: !row.busy && !row.device.pairing
                                        text: row.confirmForget ? "Confirm forget" : "Forget"
                                        onClicked: {
                                            if (row.confirmForget) {
                                                root.forgetAddress = "";
                                                row.device.forget();
                                            } else {
                                                root.forgetAddress = row.device.address;
                                                forgetTimeout.restart();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        LabelText {
                            anchors.centerIn: parent
                            visible: !deviceList.visible || deviceList.count === 0
                            color: root.muted
                            text: !root.adapter ? "No Bluetooth adapter detected"
                                : root.adapter.state === BluetoothAdapterState.Blocked ? "Bluetooth is blocked"
                                : !root.adapter.enabled ? "Bluetooth is off"
                                : root.adapter.discovering ? "Looking for nearby devices…" : "No devices yet. Start a scan to find one."
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        LabelText {
                            Layout.fillWidth: true
                            color: root.muted
                            text: "For devices that require a PIN or passkey"
                        }
                        ActionButton {
                            text: "PIN pairing…"
                            enabled: root.adapter?.enabled ?? false
                            onClicked: {
                                Quickshell.execDetached(["overskride"]);
                                root.dismiss();
                            }
                        }
                    }
                }
            }
        }
    }
}
