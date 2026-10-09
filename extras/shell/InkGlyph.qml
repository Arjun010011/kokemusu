import QtQuick
import qs.Commons

// Kokemusu: draws one icon glyph centred on its visible ink, both ways.
// Fonts place glyphs on a shared line box, so Nerd Font icons tend to sit a
// pixel or two off centre; this measures the glyph and moves it into place.
Item {
  id: root

  property string glyph: ""
  property color color: Color.foreground
  property string fontFamily: Style.font.family
  property real fontSize: Style.bar.iconFont

  TextMetrics {
    id: ink
    font: text.font
    text: root.glyph
  }

  Text {
    id: text
    textFormat: Text.PlainText
    text: root.glyph
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: Math.max(1, Math.round(root.fontSize))
    renderType: Text.NativeRendering
    x: Math.round(root.width / 2 - (ink.tightBoundingRect.x + ink.tightBoundingRect.width / 2))
    y: Math.round(root.height / 2 - (ink.tightBoundingRect.y + ink.tightBoundingRect.height / 2) - baselineOffset)

    Behavior on color { ColorAnimation { duration: 160 } }
  }
}
