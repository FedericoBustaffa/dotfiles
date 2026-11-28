pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    readonly property color accent: Theme.accent
    readonly property color foreground: Theme.foreground
    readonly property color muted: Theme.muted
    readonly property string backend: Quickshell.env("HOME") + "/dotfiles/quickshell/.config/quickshell/network-manager/network.py"
    property var snapshot: null
    property string snapshotJson: ""
    readonly property var wifi: snapshot?.devices.find(device => device.wifi) ?? null
    readonly property var wired: snapshot?.devices.filter(device => !device.wifi) ?? []
    property var passwordNetwork: null
    property string forgetPath: ""
    property string message: ""
    property string statusError: ""
    property string pendingRequest: ""

    function submit(verb, device, ap, extra) {
        if (operation.running) return;
        root.message = "";
        root.pendingRequest = JSON.stringify(Object.assign({ verb: verb, device: device?.path, ap: ap?.path }, extra ?? {}));
        operation.running = true;
    }

    function connectTo(network) {
        if (!network.saved && (network.mode === "wpa-psk" || network.mode === "sae")) {
            root.passwordNetwork = network;
            password.forceActiveFocus();
        } else {
            root.submit("connect", root.wifi, network);
        }
    }

    function join() {
        if (!password.text || !passwordNetwork || operation.running) return;
        submit("connect", wifi, passwordNetwork, { password: password.text });
        cancelPassword();
    }

    function cancelPassword() {
        password.clear();
        passwordNetwork = null;
        surface.forceActiveFocus();
    }

    Process {
        id: refresh
        command: ["python", root.backend, "status"]
        stderr: StdioCollector { id: refreshErrors }
        stdout: StdioCollector { id: statusOutput }
        onExited: (code, _status) => {
            try {
                const result = JSON.parse(statusOutput.text);
                if (code !== 0 || result.error) throw new Error(result.error || "Could not read network status.");
                if (root.snapshotJson !== statusOutput.text) {
                    const selected = networks.currentItem?.modelData;
                    const wasFocused = networks.activeFocus;
                    root.snapshotJson = statusOutput.text;
                    root.snapshot = result;
                    const index = selected ? (root.wifi?.networks ?? []).findIndex(entry =>
                        entry.name === selected.name && entry.security === selected.security) : -1;
                    if (index >= 0) networks.currentIndex = index;
                    if (wasFocused && !networks.activeFocus && networks.count > 0)
                        networks.forceActiveFocus(Qt.TabFocusReason);
                }
                root.statusError = "";
            } catch (error) {
                root.statusError = statusOutput.text ? error.message : refreshErrors.text.includes("No module named")
                    || refreshErrors.text.includes("Namespace NM") ? "Install python-gobject and libnm to use this panel." : "Could not read NetworkManager status.";
            }
        }
    }

    Process {
        id: operation
        command: ["python", root.backend]
        stdinEnabled: true
        stdout: StdioCollector { id: operationOutput }
        onStarted: {
            write(root.pendingRequest + "\n");
            root.pendingRequest = "";
        }
        onExited: (code, _status) => {
            root.pendingRequest = "";
            if (code !== 0) {
                try { root.message = JSON.parse(operationOutput.text).error || "Network action failed."; }
                catch (_error) { root.message = "Network action failed."; }
            }
            refresh.running = true;
        }
    }

    Timer { interval: 2000; repeat: true; running: true; triggeredOnStart: true; onTriggered: refresh.running = true }
    Timer { id: forgetTimeout; interval: 4000; onTriggered: root.forgetPath = "" }

    component LabelText: Text {
        color: Theme.menuText()
        font.pixelSize: Theme.menuBodyFontSize
        textFormat: Text.PlainText
        verticalAlignment: Text.AlignVCenter
    }

    component ActionButton: Button {
        id: button
        property bool accented: false
        implicitHeight: 32
        padding: 8
        leftPadding: 12
        rightPadding: 12
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus
        Keys.onReturnPressed: button.clicked()
        Keys.onEnterPressed: button.clicked()
        contentItem: Text {
            text: button.text
            color: Theme.menuText()
            font.pixelSize: Theme.menuBodyFontSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 8
            color: !button.enabled ? Theme.disabled : button.hovered ? Theme.buttonHover : Theme.button
            border.color: button.visualFocus || (button.accented && button.enabled) ? Theme.accent : Theme.outline
            border.width: button.visualFocus ? 2 : 1
        }
    }

    PanelWindow {
        screen: Quickshell.screens.find(screen => screen.name === Quickshell.env("NETWORK_MANAGER_OUTPUT"))
            ?? Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: Theme.managerScrim
        WlrLayershell.namespace: "network-manager"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: surface
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.passwordNetwork ? root.cancelPassword() : card.dismissFromKeyboard()
            TapHandler {
                onTapped: point => {
                    if (!card.contains(card.mapFromItem(surface, point.position))) Qt.quit();
                }
            }

            DropUpCard {
                id: card
                width: Math.min(560, surface.width - 32)
                height: Math.min(480, surface.height - 32)
                color: Theme.background
                border.color: Theme.outline

                ColumnLayout {
                    anchors { fill: parent; margins: 18 }
                    spacing: 10

                    RowLayout {
                        LabelText { Layout.fillWidth: true; text: "Network"; font { pixelSize: Theme.menuTitleFontSize; bold: true } }
                        ActionButton {
                            text: "Close"
                            Component.onCompleted: forceActiveFocus(Qt.TabFocusReason)
                            onClicked: Qt.quit()
                        }
                    }

                    Repeater {
                        model: root.wired
                        RowLayout {
                            id: ethernet
                            required property var modelData
                            readonly property bool connected: modelData.state === "activated"
                            LabelText {
                                Layout.fillWidth: true
                                text: "Ethernet · " + ethernet.modelData.iface + (ethernet.connected
                                    ? "  ·  Connected" + (ethernet.modelData.ip ? "  ·  " + ethernet.modelData.ip : "")
                                    : "  ·  " + ethernet.modelData.state)
                                elide: Text.ElideRight
                            }
                            ActionButton {
                                text: ethernet.connected ? "Disconnect" : "Connect"
                                enabled: !operation.running && (ethernet.connected || ethernet.modelData.state === "disconnected")
                                onClicked: root.submit(ethernet.connected ? "disconnect" : "wired", ethernet.modelData)
                            }
                        }
                    }

                    RowLayout {
                        LabelText { Layout.fillWidth: true; text: "Wi-Fi"; font { pixelSize: Theme.menuSubtitleFontSize; bold: true } }
                        Switch {
                            text: "Wi-Fi power"
                            Accessible.name: text
                            contentItem: Item {}
                            implicitWidth: implicitIndicatorWidth + leftPadding + rightPadding
                            enabled: !!root.wifi && !!root.snapshot?.wifiHardwareEnabled && !operation.running
                            checked: root.snapshot?.wifiEnabled ?? false
                            onToggled: root.submit("radio", null, null, { enabled: checked })
                        }
                        ActionButton {
                            text: "Scan"
                            accented: true
                            enabled: !!root.wifi && !!root.snapshot?.wifiEnabled && !operation.running
                            onClicked: root.submit("scan", root.wifi)
                        }
                    }

                    RowLayout {
                        visible: !!root.passwordNetwork
                        LabelText {
                            Layout.maximumWidth: 120
                            elide: Text.ElideRight
                            text: root.passwordNetwork?.name ?? ""
                        }
                        TextField {
                            id: password
                            Layout.fillWidth: true
                            placeholderText: "Wi-Fi password"
                            font.pixelSize: Theme.menuBodyFontSize
                            echoMode: TextInput.Password
                            onAccepted: root.join()
                        }
                        ActionButton { text: "Join"; accented: true; enabled: !!password.text && !operation.running; onClicked: root.join() }
                        ActionButton { text: "Cancel"; onClicked: root.cancelPassword() }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: networks
                            anchors.fill: parent
                            clip: true
                            spacing: 6
                            model: root.snapshot?.wifiEnabled ? (root.wifi?.networks ?? []) : []
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
                                readonly property bool confirmForget: root.forgetPath === modelData.path
                                width: networks.width - 10
                                height: 56
                                radius: 10
                                color: Theme.raised
                                border.width: 2
                                border.color: ListView.isCurrentItem && networks.activeFocus ? Theme.accent : "transparent"

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 10; rightMargin: 8 }
                                    spacing: 6
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        LabelText {
                                            Layout.fillWidth: true
                                            text: row.modelData.name
                                            color: Theme.menuText(row.modelData.active)
                                            font.bold: row.modelData.active
                                            elide: Text.ElideRight
                                        }
                                        LabelText {
                                            Layout.fillWidth: true
                                            color: row.modelData.active ? root.accent : root.muted
                                            elide: Text.ElideRight
                                            text: (row.modelData.active ? "Connected  ·  " : row.modelData.saved ? "Saved  ·  " : "")
                                                + row.modelData.security + "  ·  " + row.modelData.signal + "% signal"
                                        }
                                    }
                                    ActionButton {
                                        id: primary
                                        onActiveFocusChanged: if (activeFocus) networks.currentIndex = row.index
                                        text: row.modelData.active ? "Disconnect" : "Connect"
                                        enabled: !operation.running && !!(row.modelData.active || row.modelData.saved || row.modelData.mode)
                                        accented: !row.modelData.active
                                        onClicked: {
                                            if (row.modelData.active) root.submit("disconnect", root.wifi);
                                            else root.connectTo(row.modelData);
                                        }
                                    }
                                    ActionButton {
                                        visible: row.modelData.saved
                                        onActiveFocusChanged: if (activeFocus) networks.currentIndex = row.index
                                        enabled: !operation.running
                                        text: row.confirmForget ? "Confirm forget" : "Forget"
                                        onClicked: {
                                            if (row.confirmForget) {
                                                root.forgetPath = "";
                                                root.submit("forget", root.wifi, row.modelData);
                                            } else {
                                                root.forgetPath = row.modelData.path;
                                                forgetTimeout.restart();
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        LabelText {
                            anchors.centerIn: parent
                            visible: networks.count === 0
                            color: root.muted
                            text: !root.snapshot ? "" : !root.wifi ? "No Wi-Fi adapter detected"
                                : !root.snapshot.wifiHardwareEnabled ? "Wi-Fi is blocked by hardware"
                                : !root.snapshot.wifiEnabled ? "Wi-Fi is off" : "No networks found. Try scanning."
                        }
                    }

                    RowLayout {
                        LabelText {
                            Layout.fillWidth: true
                            color: root.message || root.statusError ? Theme.networkErrorText : root.muted
                            wrapMode: Text.Wrap
                            text: root.message || root.statusError || (operation.running ? "Working…" : "Hidden networks, enterprise Wi-Fi, and VPNs")
                        }
                        ActionButton {
                            text: "Advanced settings…"
                            onClicked: { Quickshell.execDetached(["nm-connection-editor"]); Qt.quit(); }
                        }
                    }
                }
            }
        }
    }
}
