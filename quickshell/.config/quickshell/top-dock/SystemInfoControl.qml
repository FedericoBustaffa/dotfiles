pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "./theme"

DockButton {
    id: control
    glyph: "󰣇"
    implicitWidth: 26
    drawerOpen: progress > 0
    Accessible.name: "System information"
    property bool yieldDrawer: false
    readonly property int drawerDepth: 345
    readonly property real progress: reveal.progress
    property var info: ({})
    property double lastRefresh: 0
    property string error: ""

    onHoveredChanged: if (hovered && !fetch.running && Date.now() - lastRefresh > 30000) {
        error = "";
        fetch.running = true;
    }

    function gib(bytes) { return (bytes / 1073741824).toFixed(1); }
    function usage(used, total) {
        return total > 0 ? gib(used) + " / " + gib(total) + " GiB" : "";
    }
    function uptime(ms) {
        if (!Number.isFinite(ms)) return "";
        const minutes = Math.floor(ms / 60000);
        const days = Math.floor(minutes / 1440);
        const hours = Math.floor(minutes / 60) % 24;
        return (days ? days + "d " : "") + (hours ? hours + "h " : "") + minutes % 60 + "m";
    }

    HoverReveal {
        id: reveal
        triggerHovered: control.hovered
        blocked: control.yieldDrawer
    }

    Process {
        id: fetch
        command: ["fastfetch", "--config", "none", "--format", "json", "--structure", "OS:Host:Kernel:Uptime:WM:CPU:GPU:Memory:Disk"]
        stdout: StdioCollector { id: output }
        onExited: (code, status) => {
            try {
                if (code !== 0 || status !== 0) throw new Error("fastfetch failed");
                const values = {};
                for (const module of JSON.parse(output.text)) {
                    if (module.result) values[module.type] = module.result;
                }
                if (!Object.keys(values).length) throw new Error("No system information");
                control.info = values;
                control.lastRefresh = Date.now();
            } catch (_) {
                control.error = "System information unavailable";
            }
        }
    }

    readonly property Component drawer: Rectangle {
        id: card
        readonly property int expandedHeight: control.drawerDepth
        implicitWidth: 368
        implicitHeight: Math.round(expandedHeight * control.progress)
        visible: height > 0
        clip: true
        color: Theme.background
        bottomLeftRadius: 16
        bottomRightRadius: 16
        Component.onDestruction: reveal.drawerHovered = false
        HoverHandler { onHoveredChanged: reveal.drawerHovered = hovered }

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    radius: 13
                    color: Theme.dockHover
                    CenteredGlyph { text: "󰣇"; color: Theme.accent; font.pixelSize: 28 }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    DockLabel {
                        Layout.fillWidth: true
                        text: control.info.OS?.prettyName || "System information"
                        font { pixelSize: Theme.menuTitleFontSize; bold: true }
                        elide: Text.ElideRight
                    }
                    DockLabel {
                        Layout.fillWidth: true
                        text: control.info.Host?.name || control.error || "Reading system details…"
                        color: Theme.muted
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.outline }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8
                Repeater {
                    model: {
                        const data = control.info;
                        const disk = data.Disk?.find(volume => volume.mountpoint === "/");
                        return [
                            { icon: "", label: "Processor", value: data.CPU?.cpu?.replace(/^\d+\w+ Gen /, "").replace(/\((R|TM)\)/g, "") },
                            { icon: "󰢮", label: "Graphics", value: data.GPU?.map(gpu => gpu.name).filter(Boolean).join(", ") },
                            { icon: "", label: "Memory", value: control.usage(data.Memory?.used, data.Memory?.total) },
                            { icon: "", label: "Root disk", value: control.usage(disk?.bytes?.total - disk?.bytes?.free, disk?.bytes?.total) },
                            { icon: "", label: "Kernel", value: data.Kernel?.release },
                            { icon: "󰖲", label: "Desktop", value: [data.WM?.prettyName, data.WM?.version].filter(Boolean).join(" ") },
                            { icon: "󰥔", label: "Uptime", value: control.uptime(data.Uptime?.uptime) },
                            { icon: "󰘚", label: "CPU threads", value: data.CPU?.cores?.logical }
                        ];
                    }
                    delegate: Rectangle {
                        id: tile
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 55
                        radius: 8
                        color: Theme.raised
                        ColumnLayout {
                            anchors { fill: parent; margins: 7 }
                            spacing: 2
                            DockReadout {
                                Layout.alignment: Qt.AlignLeft
                                icon: tile.modelData.icon
                                iconColor: Theme.accent
                                text: tile.modelData.label
                            }
                            DockLabel {
                                Layout.fillWidth: true
                                text: tile.modelData.value || "—"
                                elide: Text.ElideRight
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
