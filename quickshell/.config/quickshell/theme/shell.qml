pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "."
import "Fuzzy.js" as Fuzzy

ShellRoot {
    id: root
    property string pendingTheme: ""

    function choose(id: string): void {
        if (Theme.saving) return;
        if (id === Theme.current) {
            card.dismiss();
        } else {
            root.pendingTheme = id;
            Theme.select(id);
        }
    }

    Connections {
        target: Theme
        function onCurrentChanged() {
            if (root.pendingTheme === Theme.current) card.dismiss();
        }
    }

    PanelWindow {
        screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0] ?? null
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: card.scrim(Theme.managerScrim)
        WlrLayershell.namespace: "theme-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: surface
            anchors.fill: parent
            TapHandler {
                onTapped: point => {
                    if (!card.contains(card.mapFromItem(surface, point.position))) card.dismiss();
                }
            }

            DropUpCard {
                id: card
                width: Math.min(420, surface.width - 32)
                height: Math.min(280, surface.height - 32)
                color: Theme.background
                border.color: Theme.outline

                ColumnLayout {
                    anchors { fill: parent; margins: 16 }
                    spacing: 10

                    Text {
                        text: "Themes"
                        color: Theme.foreground
                        font { pixelSize: Theme.menuTitleFontSize; bold: true }
                    }

                    TextField {
                        id: search
                        Layout.fillWidth: true
                        implicitHeight: 38
                        leftPadding: 10
                        rightPadding: 10
                        placeholderText: "Search themes…"
                        color: Theme.foreground
                        placeholderTextColor: Theme.muted
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.background
                        font.pixelSize: Theme.menuBodyFontSize
                        background: Rectangle { radius: 8; color: Theme.raised; border.color: Theme.outline }
                        Component.onCompleted: forceActiveFocus()
                        Keys.onEscapePressed: card.dismissFromKeyboard()
                        Keys.onDownPressed: if (results.count) results.currentIndex = (results.currentIndex + 1) % results.count
                        Keys.onUpPressed: if (results.count) results.currentIndex = (results.currentIndex + results.count - 1) % results.count
                        onAccepted: {
                            const choice = results.model[results.currentIndex];
                            if (choice) root.choose(choice.id);
                        }
                    }

                    ListView {
                        id: results
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        keyNavigationEnabled: false
                        model: {
                            return Fuzzy.search(Theme.choices, search.text, choice => choice.label, choice => [choice.id]);
                        }
                        onModelChanged: {
                            currentIndex = count ? 0 : -1;
                            positionViewAtBeginning();
                        }

                        delegate: SelectionOutline {
                            id: row
                            required property var modelData
                            readonly property bool highlighted: ListView.isCurrentItem
                            width: results.width
                            height: 36
                            radius: 8
                            color: highlighted ? Theme.selectedButton : hover.hovered ? Theme.buttonHover : Theme.raised
                            borderColor: highlighted ? Theme.accent : "transparent"
                            Accessible.role: Accessible.Button
                            Accessible.name: modelData.label + (modelData.id === Theme.current ? " (active)" : "")
                            Accessible.onPressAction: root.choose(modelData.id)

                            Text {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                text: row.modelData.label
                                color: Theme.menuText(row.highlighted || row.modelData.id === Theme.current)
                                font.pixelSize: Theme.menuBodyFontSize
                            }
                            Text {
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                visible: row.modelData.id === Theme.current
                                text: "Active"
                                color: Theme.accent
                                font.pixelSize: Theme.bodyFontSize
                            }
                            HoverHandler { id: hover }
                            TapHandler { onTapped: root.choose(row.modelData.id) }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !results.count
                            text: "No matching themes"
                            color: Theme.muted
                            font.pixelSize: Theme.bodyFontSize
                        }
                    }
                    Text {
                        visible: !!Theme.error
                        text: Theme.error
                        color: Theme.errorText
                        font.pixelSize: Theme.bodyFontSize
                    }
                }
            }
        }
    }
}
