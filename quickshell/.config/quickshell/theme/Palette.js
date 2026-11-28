.import Quickshell as QS

function returnToPalette(query) {
    if (!query?.startsWith(">")) return;
    const shell = QS.Quickshell;
    shell.execDetached(["env", "QUICKSHELL_PALETTE_QUERY=" + query,
        "quickshell", "-n", "-p", shell.shellDir + "/../app-launcher"]);
}

function dismissFromKeyboard() {
    returnToPalette(QS.Quickshell.env("QUICKSHELL_PALETTE_PARENT"));
    Qt.quit();
}
