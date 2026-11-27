pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
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

    readonly property color accent: Theme.accent
    readonly property string directory: Quickshell.env("HOME") + "/dotfiles/quickshell/.config/quickshell/top-dock"
    property var status: ({})
    property string profileError: ""
    readonly property var powerProfiles: ["power-saver", "balanced", "performance"].filter(
        profile => (status.profiles ?? "").split(",").includes(profile))
    readonly property string nextPowerProfile: powerProfiles.length > 1
        ? powerProfiles[(powerProfiles.indexOf(status.profile) + 1) % powerProfiles.length] : ""
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
                DockLabel { text: levelOsd.isBrightness ? "󰃠" : levelOsd.muted ? "󰝟" : "󰕾"; font.pixelSize: 16 }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 3
                    color: Theme.outline
                    Rectangle {
                        width: parent.width * (levelOsd.muted ? 0 : Math.min(levelOsd.level, 1))
                        height: parent.height
                        radius: 3
                        color: root.accent
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
        command: ["bash", root.directory + "/status.sh"]
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

    component DockButton: Button {
        id: control
        property string glyph: ""
        property color glyphColor: Theme.foreground
        implicitWidth: Math.max(26, implicitContentWidth + 12)
        implicitHeight: 24
        padding: 0
        hoverEnabled: true
        focusPolicy: Qt.NoFocus
        background: Rectangle {
            radius: 7
            color: control.hovered ? Theme.outline : "transparent"
        }
        contentItem: DockReadout {
            icon: control.glyph
            iconColor: control.glyphColor
            text: control.text
        }
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: output
            required property var modelData
            readonly property var monitor: Hyprland.monitorFor(modelData)
            readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 0
            readonly property var visibleWorkspaceIds: {
                const ids = Hyprland.workspaces.values.filter(workspace =>
                    workspace.id >= 1 && workspace.id <= 10 && workspace.toplevels.values.length > 0
                    && (Quickshell.screens.length === 1 || workspace.monitor?.name === output.modelData.name)
                ).map(workspace => workspace.id);
                if (activeWorkspaceId > 0 && !ids.includes(activeWorkspaceId))
                    ids.push(activeWorkspaceId);
                return ids.sort((a, b) => a - b);
            }
            readonly property int activeIndex: visibleWorkspaceIds.indexOf(activeWorkspaceId)

            DockPanel {
                screen: output.modelData
                position: "left"

                DockLabel { text: "󰣇"; hint: "Arch Linux"; color: Theme.accent; font.pixelSize: 16 }
                DockReadout { visible: !!root.status.cpu; icon: ""; iconColor: Theme.dockIcons.cpu; text: root.status.cpu ?? ""; hint: "CPU usage" }
                DockReadout { visible: !!root.status.temp; icon: ""; iconColor: Theme.dockIcons.temperature; text: root.status.temp ?? ""; hint: "CPU temperature" }
                DockReadout { visible: !!root.status.memory; icon: ""; iconColor: Theme.dockIcons.memory; text: root.status.memory ?? ""; hint: "Memory usage" }
                DockReadout { visible: !!root.status.disk; icon: ""; iconColor: Theme.dockIcons.disk; text: root.status.disk ?? ""; hint: "Root disk usage" }
            }

            DockPanel {
                screen: output.modelData

                Item {
                    id: workspaceStrip
                    readonly property int buttonWidth: 26
                    readonly property int buttonSpacing: Theme.dockSpacing
                    visible: output.visibleWorkspaceIds.length > 0
                    implicitWidth: workspaceRow.implicitWidth
                    implicitHeight: 24

                    Rectangle {
                        x: Math.max(0, output.activeIndex) * (workspaceStrip.buttonWidth + workspaceStrip.buttonSpacing)
                        width: workspaceStrip.buttonWidth
                        height: workspaceStrip.height
                        radius: 7
                        color: Theme.selectedButton
                        border.color: root.accent
                        opacity: output.activeIndex >= 0 ? 1 : 0
                        Behavior on x { NumberAnimation { duration: 210; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                    }

                    Row {
                        id: workspaceRow
                        spacing: workspaceStrip.buttonSpacing
                        Repeater {
                            model: output.visibleWorkspaceIds
                            DockButton {
                                id: workspaceButton
                                required property int modelData
                                readonly property bool selected: output.activeWorkspaceId === modelData
                                width: workspaceStrip.buttonWidth
                                text: String(modelData)
                                background: Rectangle {
                                    radius: 7
                                    color: workspaceButton.hovered && !workspaceButton.selected ? Theme.outline : "transparent"
                                }
                                Accessible.name: `Workspace ${modelData}`
                                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData} })`)
                            }
                        }
                    }
                }

                Rectangle {
                    visible: workspaceStrip.visible
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    color: Theme.outline
                }
                DockLabel { text: Qt.formatDateTime(clock.date, "ddd d MMM · HH:mm") }
                DockButton {
                    glyph: notifications.dnd ? "󰂛" : notifications.count ? "󱅫" : "󰂜"
                    text: notifications.count ? String(notifications.count) : ""
                    Accessible.name: "Notifications"
                    onClicked: notifications.toggle(output.modelData)
                }
            }

            DockPanel {
                screen: output.modelData
                position: "right"

                VolumeControl {
                    id: volumeControl
                    audio: root.audio
                    onAdjustingChanged: {
                        if (adjusting) root.adjustingControl = volumeControl;
                        else if (root.adjustingControl === volumeControl) root.adjustingControl = null;
                    }
                }
                DockButton {
                    visible: !!root.bluetoothAdapter
                    glyph: !root.bluetoothAdapter?.enabled ? "󰂲" : root.bluetoothConnected ? "󰂱" : "󰂯"
                    glyphColor: root.bluetoothAdapter?.enabled ? Theme.dockIcons.bluetooth : Theme.muted
                    Accessible.name: "Bluetooth settings"
                    onClicked: Quickshell.execDetached([
                        "env", "BLUETOOTH_MANAGER_OUTPUT=" + output.modelData.name, "quickshell", "-n", "-p",
                        Quickshell.env("HOME") + "/dotfiles/quickshell/.config/quickshell/bluetooth-manager"
                    ])
                }
                DockButton {
                    visible: !!root.status.network
                    glyph: root.status.network === "Wired" ? "󰈀" : root.status.network === "Wi-Fi" ? "󰖩" : "󰖪"
                    glyphColor: root.status.network === "Wired" ? Theme.dockIcons.wired
                        : root.status.network === "Wi-Fi" ? Theme.dockIcons.wifi : Theme.muted
                    Accessible.name: "Network settings"
                    onClicked: Quickshell.execDetached([
                        "env", "NETWORK_MANAGER_OUTPUT=" + output.modelData.name, "quickshell", "-n", "-p",
                        Quickshell.env("HOME") + "/dotfiles/quickshell/.config/quickshell/network-manager"
                    ])
                }
                DockButton {
                    visible: !!root.status.profile
                    glyph: root.status.profile === "performance" ? "" : root.status.profile === "power-saver" ? "" : ""
                    glyphColor: root.status.profile === "performance" ? Theme.dockIcons.performance
                        : root.status.profile === "power-saver" ? Theme.dockIcons.powerSaver : Theme.dockIcons.balanced
                    readonly property string description: "Power profile: " + (root.status.profile ?? "")
                        + (root.nextPowerProfile ? " · Click for " + root.nextPowerProfile : "")
                    Accessible.name: description
                    ToolTip.visible: hovered && !!root.profileError
                    ToolTip.delay: 350
                    ToolTip.text: root.profileError
                    onClicked: {
                        if (profileProcess.running || !root.nextPowerProfile) return;
                        root.profileError = "";
                        profileProcess.exec(["powerprofilesctl", "set", root.nextPowerProfile]);
                    }
                }
                DockReadout { visible: !!root.status.battery; icon: "󰁹"; iconColor: Theme.dockIcons.battery; text: root.status.battery ?? "" }
            }
        }
    }
}
