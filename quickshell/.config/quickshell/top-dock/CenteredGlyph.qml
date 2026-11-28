import QtQuick

DockLabel {
    id: glyph
    anchors.centerIn: parent
    // Nerd Font glyphs can have unequal side bearings; center the visible ink.
    anchors.horizontalCenterOffset: ((metrics.advanceWidth - metrics.tightBoundingRect.width) / 2 - metrics.tightBoundingRect.x) / 2
    TextMetrics { id: metrics; font: glyph.font; text: glyph.text }
}
