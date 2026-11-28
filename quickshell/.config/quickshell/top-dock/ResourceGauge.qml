pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "./theme"

Item {
    id: gauge
    required property var metrics
    property string title: ""
    property bool secondReadoutOnArc: false
    Layout.fillWidth: true
    implicitHeight: 210
    readonly property real arcRadius: Math.max(0, Math.min(width, height) / 2 - 7)

    Repeater {
        model: 2
        delegate: Item {
            id: half
            required property int index
            readonly property var reading: gauge.metrics[index]
            readonly property string displayValue: (reading.display ?? reading.value) || "—"
            anchors.fill: parent
            readonly property bool isLeft: index === 0
            readonly property bool onArc: gauge.secondReadoutOnArc && !isLeft
            readonly property bool largeReadout: !onArc
            readonly property real midAngle: (start + span / 2) * Math.PI / 180
            readonly property real start: (isLeft ? 96 : 84) + 45
            readonly property real span: isLeft ? 168 : -168
            property real fraction: Math.max(0, Math.min(1, (parseFloat(reading.value) || 0) / 100))
            Behavior on fraction { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Repeater {
                model: half.onArc ? 2 : 1
                delegate: Shape {
                    id: segment
                    required property int index
                    // Leave a real 36° gap for the secondary readout, with round caps on both ends.
                    readonly property real offset: index === 0 ? 0 : 102 / 168
                    readonly property real length: half.onArc ? 66 / 168 : 1
                    readonly property real fill: Math.max(0, Math.min(1, half.fraction * (half.onArc ? 2 : 1) - index))
                    readonly property real startAngle: half.start + half.span * offset
                    readonly property real sweepAngle: half.span * length
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: Theme.outline
                        strokeWidth: 6
                        capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: gauge.width / 2; centerY: gauge.height / 2
                            radiusX: gauge.arcRadius; radiusY: gauge.arcRadius
                            startAngle: segment.startAngle; sweepAngle: segment.sweepAngle
                        }
                    }
                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: segment.fill > 0 ? half.reading.tint : "transparent"
                        strokeWidth: 6
                        capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: gauge.width / 2; centerY: gauge.height / 2
                            radiusX: gauge.arcRadius; radiusY: gauge.arcRadius
                            startAngle: segment.startAngle; sweepAngle: segment.sweepAngle * segment.fill
                        }
                    }
                }
            }

            Item {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: half.onArc ? gauge.arcRadius * Math.cos(half.midAngle) : 0
                anchors.verticalCenterOffset: half.onArc ? gauge.arcRadius * Math.sin(half.midAngle)
                    : gauge.secondReadoutOnArc ? 0 : half.isLeft ? -15 : 15
                width: readoutStack.implicitWidth
                height: readoutStack.implicitHeight
                Accessible.name: half.reading.label + ": " + half.displayValue

                Column {
                    id: readoutStack
                    anchors.centerIn: parent
                    spacing: 5
                    DockLabel {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: half.isLeft && !!gauge.title
                        text: gauge.title
                        font.pixelSize: half.largeReadout ? 20 : Theme.bodyFontSize
                        color: Theme.muted
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        DockLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            width: half.largeReadout ? 23 : 17
                            text: half.reading.glyph
                            color: half.reading.tint
                            font.pixelSize: half.largeReadout ? 20 : Theme.bodyFontSize
                            hint: half.reading.hint
                        }
                        DockLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            width: gauge.secondReadoutOnArc ? implicitWidth : Math.max(48, implicitWidth)
                            text: half.displayValue
                            font { bold: true; pixelSize: half.largeReadout ? 20 : Theme.bodyFontSize }
                            hint: half.reading.hint
                        }
                    }
                }
            }
        }
    }
}
