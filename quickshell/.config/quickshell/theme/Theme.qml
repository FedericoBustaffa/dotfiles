pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: theme
    readonly property var choices: [
        { id: "original", label: "Original" },
        { id: "vague", label: "Vague" },
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
    readonly property bool vague: current === "vague"
    readonly property bool tokyoNight: current === "tokyo-night"

    readonly property color foreground: tokyoNight ? "#c0caf5" : vague ? "#cdcdcd" : "#e6e4e1"
    readonly property color muted: tokyoNight ? "#9aa5ce" : vague ? "#90a0b5" : "#a5a3a6"
    readonly property var dockIcons: tokyoNight ? ({
        cpu: "#7aa2f7", memory: "#bb9af7", disk: "#e0af68",
        volume: "#e0af68", bluetooth: "#7dcfff", wifi: "#bb9af7", wired: "#73daca",
        performance: "#ff9e64", balanced: "#e0af68", powerSaver: "#9ece6a",
        battery: "#9ece6a"
    }) : vague ? ({
        cpu: "#8ba9c1", memory: "#aeaed1", disk: "#e0a363",
        volume: "#f3be7c", bluetooth: "#8ba9c1", wifi: "#bb9dbd", wired: "#b4d4cf",
        performance: "#c48282", balanced: "#e8b589", powerSaver: "#99b782",
        battery: "#99b782"
    }) : ({
        cpu: "#8fbce8", memory: "#c5a6e6", disk: "#e2c28a",
        volume: "#f2d477", bluetooth: "#8fbce8", wifi: "#b999e8", wired: "#8dccbd",
        performance: "#efac8d", balanced: "#e2c28a", powerSaver: "#8dccbd",
        battery: "#8dccbd"
    })
    readonly property color accent: {
        const match = accents.text().match(new RegExp("^" + current + "=([0-9a-f]{6})$", "m"));
        return match ? "#" + match[1] : "#8dccad";
    }
    readonly property color accentHover: tokyoNight ? "#9ab8ff" : vague ? "#8ba9c1" : "#a1d9bc"
    readonly property color background: tokyoNight ? "#1a1b26" : vague ? "#141415" : "#111316"
    readonly property color raised: tokyoNight ? "#24283b" : vague ? "#1c1c24" : "#1b2023"
    readonly property color outline: tokyoNight ? "#414868" : vague ? "#454553" : "#35363c"
    readonly property color button: tokyoNight ? "#2a2e42" : vague ? "#252530" : "#2c2e35"
    readonly property color selectedButton: tokyoNight ? "#343f60" : vague ? "#333738" : "#314348"
    readonly property color buttonHover: tokyoNight ? "#414868" : vague ? "#405065" : "#3b3e46"
    readonly property color disabled: tokyoNight ? "#1f2335" : vague ? "#1c1c24" : "#202126"
    readonly property color errorText: tokyoNight ? "#f7768e" : vague ? "#e08398" : "#f0aaa7"
    readonly property color networkErrorText: tokyoNight || vague ? errorText : "#efaaaa"
    readonly property color managerScrim: tokyoNight ? "#4210111a" : vague ? "#42141415" : "#420c0d12"
    readonly property color wallpaperScrim: tokyoNight ? "#1810111a" : vague ? "#18141415" : "#180c0d12"
    readonly property color powerScrim: tokyoNight ? "#0c10111a" : vague ? "#0c141415" : "#0c0c0d12"

    // Tint custom surfaces that do not use one of the named colors above.
    function surface(base) {
        return tokyoNight ? Qt.tint(base, "#60242950") : vague ? Qt.tint(base, "#80252530") : base;
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
