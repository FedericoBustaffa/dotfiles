pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root

    function siblingConfig(name) { return Quickshell.shellDir + "/../" + name; }

    function openManager(name, outputVariable, screen) {
        Quickshell.execDetached(["env", outputVariable + "=" + screen.name,
            "quickshell", "-n", "-p", siblingConfig(name)]);
    }
    property var status: ({})
    property var workspaceOwners: ({})

    Process {
        id: workspaceRules
        running: true
        command: ["hyprctl", "workspacerules", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const owners = {};
                    for (const rule of JSON.parse(text)) {
                        if (rule.enabled && rule.monitor && /^\d+$/.test(rule.workspaceString))
                            owners[Number(rule.workspaceString)] = rule.monitor;
                    }
                    root.workspaceOwners = owners;
                } catch (_) {}
            }
        }
    }
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") workspaceRules.running = true;
        }
    }
    property string profileError: ""
    property var savedNetworks: []
    property string networkError: ""
    property string bluetoothError: ""
    property QtObject pendingBluetooth: null
    property var previousAudioDevices: []

    function isBluetoothAudio(device) { return (device?.icon ?? "").startsWith("audio-"); }

    function toggleBluetooth(entry) {
        const device = entry.device;
        if (!device || pendingBluetooth || !bluetoothAdapter?.enabled) return;
        bluetoothError = "";
        if (device.connected) {
            device.disconnect();
            return;
        }
        // Switch audio devices only after the new link is up. Leave input and other peripherals alone.
        previousAudioDevices = isBluetoothAudio(device)
            ? bluetoothAdapter.devices.values.filter(other => other.connected && isBluetoothAudio(other)) : [];
        pendingBluetooth = device;
        bluetoothTimeout.restart();
        device.connect();
    }

    Connections {
        target: root.pendingBluetooth
        function onConnectedChanged() {
            if (!root.pendingBluetooth?.connected) return;
            bluetoothTimeout.stop();
            for (const device of root.previousAudioDevices) {
                if (device?.connected) device.disconnect();
            }
            root.previousAudioDevices = [];
            root.pendingBluetooth = null;
        }
    }
    Timer {
        id: bluetoothTimeout
        interval: 15000
        onTriggered: {
            root.bluetoothError = "Bluetooth connection timed out.";
            root.previousAudioDevices = [];
            root.pendingBluetooth = null;
        }
    }

    readonly property var savedBluetooth: (bluetoothAdapter?.devices.values ?? [])
        .filter(device => device.connected || device.paired || device.bonded)
        .map(device => ({ name: device.name || device.address, active: device.connected,
            available: bluetoothAdapter.enabled && device.state !== BluetoothDeviceState.Connecting
                && device.state !== BluetoothDeviceState.Disconnecting, device: device }))
        .sort((a, b) => Number(b.active) - Number(a.active) || a.name.localeCompare(b.name))

    function refreshNetworks() { networkList.running = true; }
    Process {
        id: networkList
        command: ["python", root.siblingConfig("network-manager") + "/network.py", "quick-connections"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.savedNetworks = Array.isArray(data) ? data : [];
                    if (data.error) root.networkError = data.error;
                } catch (_) { root.savedNetworks = []; }
            }
        }
    }
    Process {
        id: networkConnect
        stderr: StdioCollector { id: connectError }
        onExited: (code, status) => {
            root.networkError = code === 0 ? "" : connectError.text.trim() || "Connection failed";
            root.refreshNetworks();
        }
    }
    readonly property var powerProfiles: ["power-saver", "balanced", "performance"].filter(
        profile => (status.profiles ?? "").split(",").includes(profile))
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothConnected: bluetoothAdapter?.devices.values.some(device => device.connected) ?? false
    readonly property var audio: Pipewire.defaultAudioSink?.audio ?? null
    property var adjustingControl: null

    Connections {
        target: Theme
        function onCurrentChanged() {
            Quickshell.execDetached(["hyprctl", "eval", 'require("decoration-theme").apply()']);
        }
    }

    NotificationCenter { id: notifications }

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    Connections {
        target: root.audio
        function onVolumeChanged() { root.showVolumeOsd(); }
        function onMutedChanged() { root.showVolumeOsd(); }
    }

    function showVolumeOsd() {
        if (!adjustingControl?.adjusting) showOsd(false);
    }

    function showOsd(brightness) {
        levelOsd.isBrightness = brightness;
        if (!levelOsd.visible) {
            levelOsd.screen = Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
                ?? Quickshell.screens[0] ?? null;
            if (!levelOsd.screen) return;
            levelOsd.visible = true;
        }
        osdTimeout.restart();
    }

    IpcHandler {
        target: "brightness"
        function display(percent: string): void {
            if (!/^[0-9]{1,3}$/.test(percent) || Number(percent) > 100) return;
            levelOsd.brightnessLevel = Number(percent) / 100;
            root.showOsd(true);
        }
    }

    Timer {
        id: osdTimeout
        interval: 1400
        // Restarting this timer should not unmap the visible popup.
        onTriggered: levelOsd.visible = false
    }

    PanelWindow {
        id: levelOsd
        property bool isBrightness: false
        property real brightnessLevel: 0
        readonly property bool muted: !isBrightness && (root.audio?.muted ?? false)
        readonly property real level: isBrightness ? brightnessLevel : (root.audio?.volume ?? 0)
        visible: false
        anchors.bottom: true
        margins.bottom: 36
        implicitWidth: 240
        implicitHeight: 44
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        color: "transparent"
        WlrLayershell.namespace: "level-osd"
        WlrLayershell.layer: WlrLayer.Overlay

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.background
            border.color: Theme.outline

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10
                DockLabel {
                    text: levelOsd.isBrightness ? "󰃠" : levelOsd.muted ? "󰝟" : "󰕾"
                    color: Theme.accent
                    font.pixelSize: 16
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.outline
                    Rectangle {
                        width: parent.width * (levelOsd.muted ? 0 : Math.min(levelOsd.level, 1))
                        height: parent.height
                        radius: 3
                        color: Theme.accent
                        Behavior on width { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
                    }
                }
                DockLabel {
                    text: levelOsd.muted ? "Muted" : Math.round(levelOsd.level * 100) + "%"
                    Layout.preferredWidth: 42
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Process {
        id: statusProcess
        command: ["bash", Quickshell.shellDir + "/status.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const snapshot = {};
                for (const line of text.split("\n")) {
                    const separator = line.indexOf("=");
                    if (separator > 0)
                        snapshot[line.slice(0, separator)] = line.slice(separator + 1);
                }
                root.status = snapshot;
            }
        }
    }

    Process {
        id: profileProcess
        stderr: StdioCollector { id: profileStderr }
        onExited: (code, _status) => {
            if (code === 0) root.status = Object.assign({}, root.status, { profile: command[2] });
            else root.profileError = profileStderr.text.trim() || "Could not change power profile";
            statusProcess.running = true;
        }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: statusProcess.running = true
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: output
            required property var modelData

            DockPanel {
                id: dockPanel
                screen: output.modelData
                extension: resources.drawer
                sideDrawerDepth: systemInfo.drawerDepth

                // A drag owns the drawer until release; otherwise the hovered button wins.
                readonly property var sideDrawers: [
                    { anchor: systemInfo, menu: systemInfo },
                    { anchor: volumeControl, menu: volumeControl },
                    { anchor: bluetoothButton, menu: bluetoothQuick },
                    { anchor: networkButton, menu: networkQuick },
                    { anchor: powerProfile, menu: powerProfile }
                ]
                readonly property var requestedMenu: volumeControl.adjusting ? volumeControl
                    : resources.hovered ? resources
                    : sideDrawers.find(entry => entry.anchor.visible && entry.anchor.hovered)?.menu ?? null
                readonly property var activeSide: sideDrawers.find(entry =>
                    entry.menu === requestedMenu && entry.menu.progress > 0)
                    ?? sideDrawers.find(entry => entry.menu.progress > 0) ?? null
                function yieldsTo(menu) { return requestedMenu !== null && requestedMenu !== menu; }
                sideExtension: activeSide?.menu.drawer ?? null
                sideAnchor: activeSide?.anchor ?? null

                leftItems: [
                    SystemInfoControl {
                        id: systemInfo
                        yieldDrawer: dockPanel.yieldsTo(systemInfo)
                    },
                    WorkspaceStrip {
                        id: workspaceStrip
                        screen: output.modelData
                        owners: root.workspaceOwners
                    },
                    Rectangle {
                        visible: workspaceStrip.visible
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        color: Theme.outline
                    }
                ]
                centerItems: [
                    DockLabel {
                        Layout.preferredWidth: 148
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: Qt.formatDateTime(clock.date, "ddd d MMM · HH:mm")
                    },
                    DockButton {
                        glyph: notifications.dnd ? "󰂛" : notifications.count ? "󱅫" : "󰂜"
                        implicitWidth: 48
                        text: notifications.count > 99 ? "99+" : notifications.count ? String(notifications.count) : ""
                        Accessible.name: "Notifications: " + notifications.count
                        onClicked: notifications.toggle(output.modelData)
                    }
                ]

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    color: Theme.outline
                }
                ResourceControl {
                    id: resources
                    snapshot: root.status
                    drawerObscured: dockPanel.activeSide !== null
                }
                VolumeControl {
                    id: volumeControl
                    audio: root.audio
                    yieldDrawer: dockPanel.yieldsTo(volumeControl)
                    onAdjustingChanged: {
                        if (adjusting) root.adjustingControl = volumeControl;
                        else if (root.adjustingControl === volumeControl) root.adjustingControl = null;
                    }
                }
                DockButton {
                    id: bluetoothButton
                    visible: !!root.bluetoothAdapter
                    glyph: !root.bluetoothAdapter?.enabled ? "󰂲" : root.bluetoothConnected ? "󰂱" : "󰂯"
                    drawerOpen: bluetoothQuick.progress > 0
                    Accessible.name: "Bluetooth settings"
                    onClicked: root.openManager("bluetooth-manager", "BLUETOOTH_MANAGER_OUTPUT", output.modelData)
                }
                DockButton {
                    id: networkButton
                    visible: !!root.status.network
                    onHoveredChanged: if (hovered) {
                        root.networkError = "";
                        root.refreshNetworks();
                    }
                    glyph: root.status.network === "Wired" ? "󰈀" : root.status.network === "Wi-Fi" ? "󰖩" : "󰖪"
                    drawerOpen: networkQuick.progress > 0
                    Accessible.name: "Network settings"
                    onClicked: root.openManager("network-manager", "NETWORK_MANAGER_OUTPUT", output.modelData)
                }
                PowerProfileControl {
                    id: powerProfile
                    profiles: root.powerProfiles
                    activeProfile: root.status.profile ?? ""
                    error: root.profileError
                    busy: profileProcess.running
                    yieldDrawer: dockPanel.yieldsTo(powerProfile)
                    onProfileRequested: profile => {
                        if (profileProcess.running || !root.powerProfiles.includes(profile)) return;
                        root.profileError = "";
                        profileProcess.exec(["powerprofilesctl", "set", profile]);
                    }
                }
                ConnectionDrawer {
                    id: bluetoothQuick
                    visible: false
                    triggerHovered: bluetoothButton.visible && bluetoothButton.hovered
                    blocked: dockPanel.yieldsTo(bluetoothQuick)
                    entries: root.savedBluetooth
                    activeColor: Theme.dockIcons.bluetooth
                    busy: !!root.pendingBluetooth
                    error: root.bluetoothError
                    message: root.bluetoothAdapter?.enabled ? "No saved devices" : "Bluetooth is off"
                    onActionRequested: entry => root.toggleBluetooth(entry)
                }
                ConnectionDrawer {
                    id: networkQuick
                    visible: false
                    triggerHovered: networkButton.visible && networkButton.hovered
                    blocked: dockPanel.yieldsTo(networkQuick)
                    entries: root.savedNetworks
                    busy: networkConnect.running
                    error: root.networkError
                    message: networkList.running ? "Loading…" : "No saved networks"
                    onActionRequested: entry => {
                        if (networkConnect.running) return;
                        root.networkError = "";
                        networkConnect.exec(["nmcli", "--wait", "20", "connection",
                            entry.active ? "down" : "up", "uuid", entry.uuid]);
                    }
                    Timer {
                        interval: 2000
                        repeat: true
                        running: networkQuick.engaged
                        onTriggered: root.refreshNetworks()
                    }
                }
                DockReadout {
                    visible: !!root.status.battery
                    icon: "󰁹"
                    iconColor: Theme.dockGlyph
                    highlightOnHover: true
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 24
                    text: root.status.battery ?? ""
                    hint: "Battery"
                }
            }
        }
    }
}
