import QtQuick

// Share the pointer handoff between a dock button and its drawer.
Item {
    id: reveal
    visible: false
    property bool triggerHovered
    property bool drawerHovered
    property bool heldOpen
    property bool blocked
    property bool immediateClose
    property int closeDelay: 180
    property int duration: 195
    property real progress: 0
    readonly property bool engaged: triggerHovered || drawerHovered || heldOpen

    function animateTo(value) {
        if (animation.running ? animation.to === value : progress === value) return;
        animation.stop();
        animation.to = value;
        animation.start();
    }

    function open() {
        if (blocked) return;
        linger.stop();
        animateTo(1);
        if (!engaged) linger.restart();
    }

    function update() {
        if (blocked) {
            linger.stop();
            if (immediateClose) {
                animation.stop();
                progress = 0;
            } else animateTo(0);
        } else if (engaged) open();
        else if (progress > 0 || animation.running) linger.restart();
    }

    onEngagedChanged: update()
    onBlockedChanged: update()
    Timer { id: linger; interval: reveal.closeDelay; onTriggered: reveal.animateTo(0) }
    NumberAnimation {
        id: animation
        target: reveal
        property: "progress"
        duration: reveal.duration
        easing.type: Easing.OutCubic
    }
}
