# Kokemusu: rebuild the bar clone's indicator files from stock and give each one
# the bar's icon size and an InkGlyph, so they line up with the other icons.
#   python3 indicators.py <stock indicators dir> <clone indicators dir>
import os, re, sys
src, dst = sys.argv[1], sys.argv[2]
block = """  // Kokemusu: same size as the other bar icons, centred on the glyph's ink.
  fontSize: Style.bar.iconFont
  iconComponent: Component {
    InkGlyph {
      glyph: root.text
      color: root.foreground
      fontFamily: root.fontFamily
      fontSize: root.fontSize
    }
  }
"""
for name in sorted(os.listdir(src)):
    if not name.endswith(".qml"):
        continue
    s = open(os.path.join(src, name)).read()
    if "import qs.Commons" not in s:
        s = s.replace("import qs.Ui\n", "import qs.Commons\nimport qs.Ui\n", 1)
    s, n = re.subn(r"(BarIndicator \{\n  id: root\n)", r"\1" + block.replace("\\", "\\\\"), s, count=1)
    if n != 1:
        print("skipped", name)
        continue
    open(os.path.join(dst, name), "w").write(s)
    print("patched", name)
