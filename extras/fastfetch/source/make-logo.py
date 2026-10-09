# Kokemusu fastfetch logo: the swan from swan.txt, inverted so it lights up,
# scaled down to fit beside the info at half-screen width, sitting in clean
# moss ripple rings with a streaked stone reflection below.
#   python3 make-logo.py swan.txt ../logo.txt [preview.ppm]
import math, os, random, subprocess, sys, tempfile
random.seed(7)
src, out_txt = sys.argv[1], sys.argv[2]
out_ppm = sys.argv[3] if len(sys.argv) > 3 else None
SCALE = 0.56

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
WATER_ROWS = 14
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

TAG = {SW: "$2", RIP: "$1", REF: "$3"}
outl = []
for cy in range(0, NH, 4):
    s, cur = "", None
    for ccx in range(CWW // 2):
        v, kinds = 0, set()
        for dx, dy, b in BITS:
            k = canvas[cy + dy][ccx * 2 + dx]
            if k: v |= b; kinds.add(k)
        if not v: s += " "; continue
        k = SW if SW in kinds else (RIP if RIP in kinds else REF)
        if TAG[k] != cur: s += TAG[k]; cur = TAG[k]
        s += chr(0x2800 + v)
    outl.append(s.rstrip())
while outl and not outl[-1].strip(): outl.pop()
open(out_txt, "w").write("\n".join(outl) + "\n")
print(f"{CWW // 2} columns x {len(outl)} rows")

if out_ppm:
    col = {SW: (207, 205, 196), RIP: (127, 166, 110), REF: (98, 99, 94)}
    with open(out_ppm, "w") as f:
        f.write(f"P3 {CWW} {NH} 255\n")
        for y in range(NH):
            f.write(" ".join("%d %d %d" % col.get(canvas[y][x], (22, 23, 22)) for x in range(CWW)) + "\n")
