# Kokemusu boot screen art (unlock.png): the same swan, rings and reflection as
# the fastfetch logo, at full resolution and drawn as fine dots, signed 苔むす.
#   python3 make-unlock.py swan.txt ../../../unlock.png
import math, os, random, subprocess, sys, tempfile
random.seed(7)
src, out_png = sys.argv[1], sys.argv[2]
SCALE = 1.0

lines = open(src).read().splitlines()
CW = max(len(l) for l in lines); W, H = CW * 2, len(lines) * 4
BITS = [(0,0,0x01),(0,1,0x02),(0,2,0x04),(1,0,0x08),(1,1,0x10),(1,2,0x20),(0,3,0x40),(1,3,0x80)]
img = [[0] * W for _ in range(H)]
for cy, l in enumerate(lines):
    for cx, ch in enumerate(l):
        v = 255 - (ord(ch) - 0x2800)
        for dx, dy, b in BITS:
            if v & b: img[cy * 4 + dy][cx * 2 + dx] = 1

# keep only the swan: the biggest connected shape, plus anything large touching it
seen = [[0] * W for _ in range(H)]
comps = []
for y in range(H):
    for x in range(W):
        if img[y][x] and not seen[y][x]:
            comp, stack = [], [(x, y)]; seen[y][x] = 1
            while stack:
                px, py = stack.pop(); comp.append((px, py))
                for nx in (px - 1, px, px + 1):
                    for ny in (py - 1, py, py + 1):
                        if 0 <= nx < W and 0 <= ny < H and img[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = 1; stack.append((nx, ny))
            comps.append(comp)
for comp in comps:
    if len(comp) < 25:
        for px, py in comp: img[py][px] = 0

body = [y for y in range(H) if sum(img[y][20:120]) > 30]
water = body[-1] + 1
ys = [y for y in range(water) if any(img[y])]
xs = [x for y in range(water) for x in range(W) if img[y][x]]
x0, x1, y0 = min(xs), max(xs), ys[0]
sw, sh = x1 - x0 + 1, water - y0

# downscale the swan with area averaging, then threshold
with tempfile.TemporaryDirectory() as tmp:
    pgm = os.path.join(tmp, "s.pgm")
    with open(pgm, "w") as f:
        f.write(f"P2 {sw} {sh} 1\n")
        for y in range(y0, water):
            f.write(" ".join(str(img[y][x]) for x in range(x0, x1 + 1)) + "\n")
    nw, nh = round(sw * SCALE), round(sh * SCALE)
    raw = subprocess.run(["magick", pgm, "-filter", "box", "-resize", f"{nw}x{nh}!", "-threshold", "46%",
                          "-compress", "none", "pgm:-"], capture_output=True, text=True).stdout.split()
    nw, nh, mx = int(raw[1]), int(raw[2]), int(raw[3])
    vals = list(map(int, raw[4:]))
    small = [[1 if vals[y * nw + x] > mx // 2 else 0 for x in range(nw)] for y in range(nh)]

# canvas: room for the rings around the swan and water below it
rings = [0.42, 0.53, 0.64]
max_rx = nw * rings[-1]
CWW = int(2 * math.ceil(max_rx) + 2); CWW += CWW % 2
WATER_ROWS = 26
NH = nh + WATER_ROWS; NH += (-NH) % 4
ox = (CWW - nw) // 2
SW, RIP, REF = 1, 2, 3
canvas = [[0] * CWW for _ in range(NH)]
for y in range(nh):
    for x in range(nw):
        if small[y][x]: canvas[y][x + ox] = SW
cx, wl = CWW / 2 - 0.5, nh

# rings: whole ellipses on the water plane; the swan hides the far side
for rf in rings:
    rx = nw * rf; ry = rx * 0.2
    steps = int(rx * 12)
    for t in range(steps):
        a = 2 * math.pi * t / steps
        x = round(cx + rx * math.cos(a)); y = round(wl + 1 + ry * math.sin(a))
        if 0 <= x < CWW and 0 <= y < NH and canvas[y][x] != SW:
            canvas[y][x] = RIP

# reflection: the swan flipped under the waterline, as short wavering streaks
for ry in range(2, NH - wl):
    if ry % 2: continue
    sy = nh - 1 - int(ry * 1.7)
    if sy < 0: break
    shift = round(1.5 * math.sin(ry * 1.3))
    fade = 1 - (ry / (NH - wl)) ** 1.2
    for x in range(CWW):
        sx = x - ox - shift
        if 0 <= sx < nw and small[sy][sx] and random.random() < 0.7 * fade:
            if canvas[wl + ry][x] == 0: canvas[wl + ry][x] = REF


PITCH, R = 2.8, 1.2
col = {SW: "#cfcdc4", RIP: "#7fa66e", REF: "#6e6f69"}
art_w, art_h = CWW * PITCH, NH * PITCH
PAD = 12
SIGN = 96
Wd, Hd = round(art_w + PAD * 2), round(art_h + PAD + SIGN)
out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{Wd}" height="{Hd}">']
for y in range(NH):
    for x in range(CWW):
        k = canvas[y][x]
        if k:
            out.append(f'<circle cx="{PAD + x*PITCH + PITCH/2:.1f}" cy="{PAD + y*PITCH + PITCH/2:.1f}" r="{R}" fill="{col[k]}"/>')
cy = round(art_h + PAD + SIGN * 0.55)
mid = Wd / 2
out.append(f'<line x1="{mid-160}" y1="{cy}" x2="{mid-72}" y2="{cy}" stroke="#4a4b47" stroke-width="1.2"/>')
out.append(f'<line x1="{mid+72}" y1="{cy}" x2="{mid+160}" y2="{cy}" stroke="#4a4b47" stroke-width="1.2"/>')
out.append(f'<text x="{mid}" y="{cy+13}" font-family="Noto Serif CJK JP" font-weight="300" font-size="36" letter-spacing="10" fill="#9a9890" text-anchor="middle">苔むす</text>')
out.append('</svg>')
import tempfile
with tempfile.NamedTemporaryFile("w", suffix=".svg", delete=False) as f:
    f.write("\n".join(out)); svg = f.name
subprocess.run(["rsvg-convert", svg, "-o", out_png], check=True)
os.unlink(svg)
print(out_png, Wd, "x", Hd)
