import QtQuick
import qs.Commons

// Kokemusu bar icons: hand-drawn hairline glyphs, one flat stroke colour.
// Widgets keep choosing their Nerd Font glyph exactly as upstream does; this
// item reads that glyph and draws the matching icon, so state (signal, volume,
// charge) keeps flowing from Omarchy's own logic. Unknown glyphs are drawn as
// the original text, so nothing ever goes blank.
Item {
  id: root

  property string glyph: ""
  property color color: Color.foreground
  property string fontFamily: Style.font.family
  property real fontSize: Style.bar.iconFont

  readonly property int cp: glyph.length > 0 ? glyph.codePointAt(0) : 0

  // glyph -> [kind, level]
  readonly property var spec: {
    var wifi = { 0xf092f: 0, 0xf091f: 1, 0xf0922: 2, 0xf0925: 3, 0xf0928: 4 }
    if (cp in wifi) return ["wifi", wifi[cp]]
    if (cp === 0xf092e) return ["wifi-off", 0]
    if (cp === 0xf0200) return ["ethernet", 0]
    if (cp === 0xf00af) return ["bluetooth", 0]
    if (cp === 0xf00b1) return ["bluetooth", 1]
    if (cp === 0xf00b2) return ["bluetooth-off", 0]
    if (cp === 0xf02cb) return ["headphones", 0]
    if (cp === 0xf028) return ["volume", 3]
    if (cp === 0xf027) return ["volume", 2]
    if (cp === 0xf026) return ["volume", 1]
    if (cp === 0xeee8) return ["volume-off", 0]
    if (cp === 0xf0379) return ["display", 1]
    if (cp === 0xf037a) return ["display", 2]
    var charging = [0xf089c, 0xf0086, 0xf0087, 0xf0088, 0xf089d, 0xf0089, 0xf089e, 0xf008a, 0xf008b, 0xf0085]
    var draining = [0xf007a, 0xf007b, 0xf007c, 0xf007d, 0xf007e, 0xf007f, 0xf0080, 0xf0081, 0xf0082, 0xf0079]
    var i = charging.indexOf(cp)
    if (i >= 0) return ["battery-charging", (i + 1) / 10]
    i = draining.indexOf(cp)
    if (i >= 0) return ["battery", (i + 1) / 10]
    return ["text", 0]
  }
  readonly property string kind: spec[0]
  readonly property real level: spec[1]

  onGlyphChanged: art.requestPaint()
  onColorChanged: art.requestPaint()
  onWidthChanged: art.requestPaint()
  onHeightChanged: art.requestPaint()

  Text {
    anchors.centerIn: parent
    visible: root.kind === "text"
    text: root.glyph
    color: root.color
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
  }

  Canvas {
    id: art
    anchors.fill: parent
    visible: root.kind !== "text"
    antialiasing: true
    renderStrategy: Canvas.Cooperative

    onPaint: {
      var c = getContext("2d")
      var s = Math.min(width, height)
      c.reset()
      if (s <= 0) return
      c.save()
      c.translate((width - s) / 2, (height - s) / 2)
      c.lineWidth = Math.max(1.1, s * 0.085)
      c.lineCap = "round"
      c.lineJoin = "round"
      var ink = root.color
      var faint = Qt.rgba(ink.r, ink.g, ink.b, ink.a * 0.28)
      function P(x) { return x * s }
      function stroke(col) { c.strokeStyle = col; c.stroke() }
      function slash() {
        c.beginPath(); c.moveTo(P(0.18), P(0.18)); c.lineTo(P(0.82), P(0.82)); stroke(ink)
      }

      var k = root.kind
      if (k === "wifi" || k === "wifi-off") {
        var cx = P(0.5), cy = P(0.8)
        var radii = [0.2, 0.4, 0.6]
        for (var a = 0; a < 3; a++) {
          c.beginPath()
          c.arc(cx, cy, P(radii[a]), Math.PI * 1.25, Math.PI * 1.75, false)
          stroke(k === "wifi" && root.level >= a + 2 ? ink : faint)
        }
        c.beginPath(); c.arc(cx, cy, P(0.06), 0, Math.PI * 2)
        c.fillStyle = k === "wifi" && root.level >= 1 ? ink : faint; c.fill()
        if (k === "wifi-off") slash()
      } else if (k === "ethernet") {
        c.beginPath()
        c.moveTo(P(0.22), P(0.78)); c.lineTo(P(0.22), P(0.36)); c.lineTo(P(0.36), P(0.36))
        c.lineTo(P(0.36), P(0.24)); c.lineTo(P(0.64), P(0.24)); c.lineTo(P(0.64), P(0.36))
        c.lineTo(P(0.78), P(0.36)); c.lineTo(P(0.78), P(0.78)); c.closePath(); stroke(ink)
        c.beginPath()
        for (var e = 0; e < 3; e++) { c.moveTo(P(0.38 + e * 0.12), P(0.78)); c.lineTo(P(0.38 + e * 0.12), P(0.62)) }
        stroke(ink)
      } else if (k === "bluetooth" || k === "bluetooth-off") {
        c.beginPath()
        c.moveTo(P(0.3), P(0.32)); c.lineTo(P(0.68), P(0.66)); c.lineTo(P(0.5), P(0.84))
        c.lineTo(P(0.5), P(0.16)); c.lineTo(P(0.68), P(0.34)); c.lineTo(P(0.3), P(0.68))
        stroke(k === "bluetooth" ? ink : faint)
        if (k === "bluetooth" && root.level > 0) {
          c.fillStyle = ink
          c.beginPath(); c.arc(P(0.18), P(0.5), P(0.05), 0, Math.PI * 2); c.fill()
          c.beginPath(); c.arc(P(0.82), P(0.5), P(0.05), 0, Math.PI * 2); c.fill()
        }
        if (k === "bluetooth-off") slash()
      } else if (k === "volume" || k === "volume-off") {
        c.beginPath()
        c.moveTo(P(0.14), P(0.4)); c.lineTo(P(0.3), P(0.4)); c.lineTo(P(0.48), P(0.22))
        c.lineTo(P(0.48), P(0.78)); c.lineTo(P(0.3), P(0.6)); c.lineTo(P(0.14), P(0.6)); c.closePath()
        stroke(ink)
        if (k === "volume") {
          for (var w = 0; w < 3; w++) {
            c.beginPath()
            c.arc(P(0.48), P(0.5), P(0.14 + w * 0.13), -Math.PI * 0.28, Math.PI * 0.28, false)
            stroke(root.level >= w + 1 ? ink : faint)
          }
        } else {
          c.beginPath()
          c.moveTo(P(0.64), P(0.38)); c.lineTo(P(0.86), P(0.62))
          c.moveTo(P(0.86), P(0.38)); c.lineTo(P(0.64), P(0.62))
          stroke(ink)
        }
      } else if (k === "headphones") {
        c.beginPath(); c.arc(P(0.5), P(0.56), P(0.32), Math.PI, 0, false); stroke(ink)
        c.beginPath()
        c.moveTo(P(0.18), P(0.56)); c.lineTo(P(0.18), P(0.8)); c.lineTo(P(0.3), P(0.8)); c.lineTo(P(0.3), P(0.58)); c.closePath()
        c.moveTo(P(0.82), P(0.56)); c.lineTo(P(0.82), P(0.8)); c.lineTo(P(0.7), P(0.8)); c.lineTo(P(0.7), P(0.58)); c.closePath()
        stroke(ink)
      } else if (k === "battery" || k === "battery-charging") {
        var x0 = P(0.1), y0 = P(0.3), bw = P(0.7), bh = P(0.4), r = P(0.08)
        c.beginPath(); c.roundedRect(x0, y0, bw, bh, r, r); stroke(ink)
        c.beginPath(); c.moveTo(P(0.88), P(0.43)); c.lineTo(P(0.88), P(0.57)); stroke(ink)
        var inset = c.lineWidth * 1.4
        var low = k === "battery" && root.level <= 0.2
        c.fillStyle = k === "battery-charging" ? Color.accent : (low ? Color.urgent : ink)
        c.beginPath()
        c.roundedRect(x0 + inset, y0 + inset, Math.max(0, (bw - inset * 2) * root.level), bh - inset * 2, r * 0.4, r * 0.4)
        c.fill()
      } else if (k === "display") {
        if (root.level > 1) {
          c.beginPath(); c.roundedRect(P(0.26), P(0.12), P(0.62), P(0.4), P(0.05), P(0.05)); stroke(faint)
        }
        c.beginPath(); c.roundedRect(P(0.12), P(0.22), P(0.66), P(0.44), P(0.06), P(0.06)); stroke(ink)
        c.beginPath()
        c.moveTo(P(0.45), P(0.66)); c.lineTo(P(0.45), P(0.8))
        c.moveTo(P(0.3), P(0.8)); c.lineTo(P(0.6), P(0.8))
        stroke(ink)
      }
      c.restore()
    }
  }
}
