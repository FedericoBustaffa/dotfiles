pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import "./theme"

Item {
    id: join
    required property Item drawer
    required property Item bar
    readonly property real curve: Math.min(20, drawer.height)
    x: drawer.x
    y: drawer.y
    width: drawer.width
    height: curve
    visible: height > 0

    Repeater {
        model: 2
        delegate: Shape {
            id: shoulder
            required property int index
            readonly property bool mirrored: index === 1
            x: mirrored ? join.width : -width
            width: Math.max(0, Math.min(join.curve, (mirrored
                ? join.bar.x + join.bar.width - join.drawer.x - join.drawer.width
                : join.drawer.x - join.bar.x)))
            height: join.curve
            preferredRendererType: Shape.CurveRenderer
            visible: width > 0
            transform: Scale { origin.x: shoulder.width / 2; xScale: shoulder.mirrored ? -1 : 1 }

            ShapePath {
                fillColor: Theme.background
                strokeWidth: -1
                // Slightly overlap the bar and drawer so fractional scaling cannot leave a seam.
                startX: 0; startY: -1
                PathLine { x: shoulder.width + 1; y: -1 }
                PathLine { x: shoulder.width + 1; y: shoulder.height }
                PathLine { x: shoulder.width; y: shoulder.height }
                PathCubic {
                    x: 0; y: 0
                    control1X: shoulder.width; control1Y: shoulder.height * 0.447715
                    control2X: shoulder.width * 0.552285; control2Y: 0
                }
                PathLine { x: 0; y: -1 }
            }
        }
    }
}
