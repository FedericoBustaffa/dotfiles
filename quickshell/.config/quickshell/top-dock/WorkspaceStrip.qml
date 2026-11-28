pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./theme"

Item {
    id: workspaceStrip
    required property ShellScreen screen
    required property var owners

    readonly property var monitor: Hyprland.monitorFor(screen)
    function ownsWorkspace(id) {
        if (Quickshell.screens.length <= 1) return true;
        const assigned = owners[id];
        if (assigned && Quickshell.screens.some(screen => screen.name === assigned))
            return assigned === screen.name;
        const workspace = Hyprland.workspaces.values.find(workspace => workspace.id === id);
        return !workspace?.monitor || workspace.monitor.name === screen.name;
    }
    readonly property int activeWorkspaceId: {
        const workspace = monitor?.activeWorkspace;
        return workspace && ownsWorkspace(workspace.id) ? workspace.id : 0;
    }
    readonly property var occupiedWorkspaceIds: Hyprland.workspaces.values.filter(workspace =>
            workspace.id >= 1 && workspace.id <= 10 && workspace.toplevels.values.length > 0
            && ownsWorkspace(workspace.id)
        ).map(workspace => workspace.id)

    readonly property int buttonWidth: 26
    readonly property int buttonSpacing: Theme.dockSpacing
    property bool ready: false
    property int previousId: 0
    property int destinationId: 0
    property real reveal: 1
    property real travel: 1
    readonly property var workspaceIds: [...new Set([
        ...workspaceStrip.occupiedWorkspaceIds, previousId, destinationId
    ].filter(id => id > 0 && workspaceStrip.ownsWorkspace(id)))].sort((a, b) => a - b)
    // Keep the numbered slots alive so occupancy changes can animate their widths.
    property var slotIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    property int slotRevision: 0
    onWorkspaceIdsChanged: {
        const extras = workspaceIds.filter(id => id > 10 && !slotIds.includes(id));
        if (extras.length) slotIds = slotIds.concat(extras).sort((a, b) => a - b);
    }
    function slotFor(id) {
        return slotRevision ? workspaceSlots.itemAt(slotIds.indexOf(id)) : null;
    }
    readonly property Item startSlot: slotFor(previousId || destinationId)
    readonly property Item endSlot: slotFor(destinationId)
    visible: implicitWidth > 0

    function switchTo(id) {
        if (id === destinationId) return;
        transition.stop();
        // Ignore a transient foreign workspace while Hyprland updates both monitors.
        if (!id && workspaceStrip.monitor?.activeWorkspace && destinationId && workspaceStrip.ownsWorkspace(destinationId)) {
            reveal = 1;
            travel = 1;
            previousId = 0;
            return;
        }
        previousId = id > 0 && workspaceStrip.ownsWorkspace(destinationId) ? destinationId : 0;
        destinationId = id;
        if (!previousId || !id) {
            reveal = 1;
            travel = 1;
            return;
        }
        travel = 0;
        reveal = workspaceStrip.occupiedWorkspaceIds.includes(id) ? 1 : 0;
        transition.start();
    }

    Component.onCompleted: {
        ready = true;
        switchTo(activeWorkspaceId);
    }
    onActiveWorkspaceIdChanged: if (ready) switchTo(activeWorkspaceId)
    SequentialAnimation {
        id: transition
        NumberAnimation {
            target: workspaceStrip; property: "reveal"; to: 1
            duration: workspaceStrip.reveal < 1 ? 175 : 0
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: workspaceStrip; property: "travel"; to: 1
            duration: 210; easing.type: Easing.OutCubic
        }
        onFinished: workspaceStrip.previousId = 0
    }
    implicitWidth: Math.max(0, workspaceRow.implicitWidth - buttonSpacing)
    implicitHeight: 24

    SelectionOutline {
        readonly property real endX: workspaceStrip.endSlot?.x ?? 0
        readonly property real startX: workspaceStrip.startSlot?.x ?? endX
        x: startX + (endX - startX) * workspaceStrip.travel
        width: workspaceStrip.buttonWidth
        height: workspaceStrip.height
        radius: 7
        color: Theme.selectedButton
        borderColor: Theme.accent
        opacity: workspaceStrip.endSlot ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Row {
        id: workspaceRow
        Repeater {
            id: workspaceSlots
            model: workspaceStrip.slotIds
            onItemAdded: workspaceStrip.slotRevision++
            onItemRemoved: workspaceStrip.slotRevision++
            Item {
                id: slot
                required property int modelData
                readonly property bool owned: workspaceStrip.ownsWorkspace(modelData)
                readonly property bool shown: workspaceStrip.workspaceIds.includes(modelData)
                readonly property real extent: shown
                    ? (modelData === workspaceStrip.destinationId ? workspaceStrip.reveal : 1) : 0
                property real presence: extent
                // The active destination already has its own reveal animation.
                Behavior on presence {
                    enabled: slot.owned && slot.modelData !== workspaceStrip.destinationId
                    NumberAnimation { duration: 175; easing.type: Easing.OutCubic }
                }
                width: owned ? presence * (workspaceStrip.buttonWidth + workspaceStrip.buttonSpacing) : 0
                height: workspaceStrip.height
                visible: width > 0

                DockButton {
                    id: workspaceButton
                    readonly property bool selected: workspaceStrip.activeWorkspaceId === slot.modelData
                    width: workspaceStrip.buttonWidth
                    text: String(slot.modelData)
                    opacity: slot.presence
                    scale: 0.75 + 0.25 * slot.presence
                    enabled: slot.shown && slot.presence > 0.5
                    background: Rectangle {
                        radius: 7
                        color: workspaceButton.hovered && !workspaceButton.selected ? Theme.dockHover : "transparent"
                    }
                    Accessible.name: `Workspace ${slot.modelData}`
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${slot.modelData} })`)
                }
            }
        }
    }
}
