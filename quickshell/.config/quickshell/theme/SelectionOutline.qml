import QtQuick
import QtQuick.Shapes

Shape {
    id: outline
    property color color: "transparent"
    property color borderColor: "transparent"
    property real radius: 8
    property real strokeWidth: 1.25
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
        fillColor: outline.color
        strokeColor: outline.borderColor
        strokeWidth: outline.strokeWidth
        PathRectangle {
            width: outline.width
            height: outline.height
            radius: outline.radius
            strokeAdjustment: outline.strokeWidth
        }
    }
}
