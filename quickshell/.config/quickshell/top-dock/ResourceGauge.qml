pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "./theme"

ColumnLayout {
    id: gauge
    required property string label
    required property string glyph
    required property color tint
    required property string value
    property string detail: ""
    property string detailIcon: ""
    property string detailHint: ""
    property real sweep: 270 * Math.max(0, Math.min(1, (parseFloat(value) || 0) / 100))
    Layout.fillWidth: true
    spacing: 2

    Behavior on sweep { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    Item {
        id: dial
        Layout.fillWidth: true
        implicitHeight: 114
        readonly property real arcRadius: Math.max(0, Math.min(width, height) / 2 - 6)

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.outline
                strokeWidth: 7
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: dial.arcRadius; radiusY: dial.arcRadius
                    startAngle: 135; sweepAngle: 270
                }
            }
            ShapePath {
                fillColor: "transparent"
                strokeColor: gauge.sweep > 0 ? gauge.tint : "transparent"
                strokeWidth: 7
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: dial.width / 2; centerY: dial.height / 2
                    radiusX: dial.arcRadius; radiusY: dial.arcRadius
                    startAngle: 135; sweepAngle: gauge.sweep
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 3
            DockLabel {
                Layout.alignment: Qt.AlignHCenter
                text: gauge.value || "—"
                font { bold: true; pixelSize: Theme.titleFontSize }
            }
            DockReadout {
                Layout.alignment: Qt.AlignHCenter
                visible: !!gauge.detail
                icon: gauge.detailIcon
                iconColor: gauge.tint
                text: gauge.detail
                hint: gauge.detailHint
            }
        }
    }

    DockReadout {
        Layout.alignment: Qt.AlignHCenter
        icon: gauge.glyph
        iconColor: gauge.tint
        text: gauge.label
    }
}
