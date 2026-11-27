pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme
    readonly property var choices: [ { id: "original", label: "Original" }, { id: "lavender", label: "Lavender" } ]
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell"
    readonly property string current: selection.text().trim() === "lavender" ? "lavender" : "original"
    readonly property bool saving: writer.running
    property string error: ""
    readonly property int dockSpacing: 12
    readonly property bool lavender: current === "lavender"

    readonly property color foreground: lavender ? "#f0e8f5" : "#e6e4e1"
    readonly property color muted: lavender ? "#b6a8c2" : "#a5a3a6"
    readonly property color accent: {
        const match = accents.text().match(new RegExp("^" + current + "=([0-9a-f]{6})$", "m"));
        return match ? "#" + match[1] : "#8dccad";
    }
    readonly property color accentHover: lavender ? "#e5d2ff" : "#a1d9bc"
    readonly property color background: lavender ? surface("#18191e") : "#111316"
    readonly property color raised: lavender ? surface("#22242a") : "#1b2023"
    readonly property color outline: surface("#35363c")
    readonly property color button: surface("#2c2e35")
    readonly property color buttonHover: surface("#3b3e46")
    readonly property color disabled: surface("#202126")
    readonly property color errorText: lavender ? "#ffb3cb" : "#f0aaa7"
    readonly property color networkErrorText: lavender ? errorText : "#efaaaa"
    readonly property color managerScrim: "#420c0d12"
    readonly property color wallpaperScrim: "#180c0d12"
    readonly property color powerScrim: "#0c0c0d12"

    // Preserve each original surface shade, adding a purple tint in Lavender.
    function surface(base) { return lavender ? Qt.tint(base, "#443f225b") : base; }

    function select(id) {
        if (saving || !choices.some(choice => choice.id === id)) return;
        error = "";
        writer.exec(["sh", "-c", 'umask 077; mkdir -p -- "$1" && tmp=$(mktemp "$1/.theme.XXXXXX") || exit 1; trap \'rm -f -- "$tmp"\' EXIT; printf "%s\\n" "$2" > "$tmp" && mv -f -- "$tmp" "$1/theme"', "theme", stateDir, id]);
    }

    FileView {
        id: accents
        path: Quickshell.env("HOME") + "/dotfiles/quickshell/.config/quickshell/theme/accents"
        blockLoading: true
    }

    FileView {
        id: selection
        path: theme.stateDir + "/theme"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    // Some filesystem watchers can't watch the state file before its first creation.
    Timer { interval: 1000; running: !selection.loaded; repeat: true; onTriggered: selection.reload() }

    Process {
        id: writer
        onExited: (code, _status) => {
            if (code !== 0) theme.error = "Could not save the theme";
            selection.reload();
        }
    }
}
