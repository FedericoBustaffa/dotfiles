pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme
    readonly property var choices: [
        { id: "original", label: "Original" },
        { id: "lavender", label: "Lavender" },
        { id: "tokyo-night", label: "Tokyo Night" }
    ]
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell"
    readonly property string current: {
        const id = selection.text().trim();
        return choices.some(choice => choice.id === id) ? id : "original";
    }
    readonly property bool saving: writer.running
    property string error: ""
    readonly property int dockSpacing: 12
    readonly property int titleFontSize: 22
    readonly property int subtitleFontSize: 16
    readonly property int bodyFontSize: 13
    readonly property bool lavender: current === "lavender"
    readonly property bool tokyoNight: current === "tokyo-night"

    readonly property color foreground: tokyoNight ? "#c0caf5" : lavender ? "#f0e8f5" : "#e6e4e1"
    readonly property color muted: tokyoNight ? "#9aa5ce" : lavender ? "#b6a8c2" : "#a5a3a6"
    readonly property var dockIcons: tokyoNight ? ({
        cpu: "#7aa2f7", temperature: "#ff9e64", memory: "#bb9af7", disk: "#e0af68",
        volume: "#e0af68", bluetooth: "#7dcfff", wifi: "#bb9af7", wired: "#73daca",
        performance: "#ff9e64", balanced: "#e0af68", powerSaver: "#9ece6a",
        battery: "#9ece6a"
    }) : lavender ? ({
        cpu: "#adbdf2", temperature: "#efaac1", memory: "#cdb6f0", disk: "#e7c99e",
        volume: "#f2d99e", bluetooth: "#adbdf2", wifi: "#ceafff", wired: "#a5d7cc",
        performance: "#efaac1", balanced: "#e7c99e", powerSaver: "#a5d7cc",
        battery: "#a5d7cc"
    }) : ({
        cpu: "#8fbce8", temperature: "#efac8d", memory: "#c5a6e6", disk: "#e2c28a",
        volume: "#f2d477", bluetooth: "#8fbce8", wifi: "#b999e8", wired: "#8dccbd",
        performance: "#efac8d", balanced: "#e2c28a", powerSaver: "#8dccbd",
        battery: "#8dccbd"
    })
    readonly property color accent: {
        const match = accents.text().match(new RegExp("^" + current + "=([0-9a-f]{6})$", "m"));
        return match ? "#" + match[1] : "#8dccad";
    }
    readonly property color accentHover: tokyoNight ? "#9ab8ff" : lavender ? "#e5d2ff" : "#a1d9bc"
    readonly property color background: tokyoNight ? "#1a1b26" : lavender ? surface("#18191e") : "#111316"
    readonly property color raised: tokyoNight ? "#24283b" : lavender ? surface("#22242a") : "#1b2023"
    readonly property color outline: tokyoNight ? "#414868" : surface("#35363c")
    readonly property color button: tokyoNight ? "#2a2e42" : surface("#2c2e35")
    readonly property color selectedButton: tokyoNight ? "#343f60" : surface("#314348")
    readonly property color buttonHover: tokyoNight ? "#414868" : surface("#3b3e46")
    readonly property color disabled: tokyoNight ? "#1f2335" : surface("#202126")
    readonly property color errorText: tokyoNight ? "#f7768e" : lavender ? "#ffb3cb" : "#f0aaa7"
    readonly property color networkErrorText: tokyoNight || lavender ? errorText : "#efaaaa"
    readonly property color managerScrim: tokyoNight ? "#4210111a" : "#420c0d12"
    readonly property color wallpaperScrim: tokyoNight ? "#1810111a" : "#180c0d12"
    readonly property color powerScrim: tokyoNight ? "#0c10111a" : "#0c0c0d12"

    // Tint custom surfaces that do not use one of the named colors above.
    function surface(base) {
        return tokyoNight ? Qt.tint(base, "#60242950") : lavender ? Qt.tint(base, "#443f225b") : base;
    }

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
