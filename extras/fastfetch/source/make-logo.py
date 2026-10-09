# Regenerate logo.txt: python3 make-logo.py swan.txt ../logo.txt /tmp/preview.ppm
import sys, math, random
random.seed(3)
src, out_txt, out_ppm = sys.argv[1:4]
lines = open(src).read().splitlines()
CW = max(len(l) for l in lines); W, H = CW*2, len(lines)*4
BITS = [(0,0,0x01),(0,1,0x02),(0,2,0x04),(1,0,0x08),(1,1,0x10),(1,2,0x20),(0,3,0x40),(1,3,0x80)]
img = [[0]*W for _ in range(H)]
for cy, l in enumerate(lines):
    for cx, ch in enumerate(l):
        v = 255 - (ord(ch) - 0x2800)          # invert: the swan lights up
        for dx, dy, b in BITS:
            if v & b: img[cy*4+dy][cx*2+dx] = 1

# keep the swan: drop small specks (8-connected components under 10 px)
seen = [[0]*W for _ in range(H)]
for y in range(H):
    for x in range(W):
        if img[y][x] and not seen[y][x]:
            comp, stack = [], [(x, y)]; seen[y][x] = 1
            while stack:
                px, py = stack.pop(); comp.append((px, py))
                for nx in (px-1, px, px+1):
                    for ny in (py-1, py, py+1):
                        if 0 <= nx < W and 0 <= ny < H and img[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = 1; stack.append((nx, ny))
            if len(comp) < 10:
                for px, py in comp: img[py][px] = 0

rows = [y for y in range(H) if any(img[y])]
top = max(0, rows[0] - 2)
# waterline: the lowest row where the body is still wide
body = [y for y in range(H) if sum(img[y][20:120]) > 30]
water = body[-1] + 1
xs = [x for y in range(water-12, water) for x in range(W) if img[y][x]]
cx = (min(xs) + max(xs)) / 2

EXTRA = 14                       # rows of new water below the picture
NH = H - top + EXTRA
SW, RIP, REF = 1, 2, 3
canvas = [[0]*W for _ in range(NH)]
for y in range(top, H):
    for x in range(W):
        if img[y][x]:
            if y < water: canvas[y-top][x] = SW
            elif random.random() < 0.35 and (y - water) % 3 != 2: canvas[y-top][x] = REF
wl = water - top

# reflection: the swan above the waterline, flipped, squashed, broken into
# wavering bands like light on water
for ry in range(0, NH - wl):
    sy = water - 1 - int(ry * 2.2)          # sample upward from the waterline
    if sy < top or ry % 3 == 2: continue    # every third row is a gap between waves
    shift = round(2.5 * math.sin(ry * 0.9))
    fade = 1 - ry / (NH - wl)
    for x in range(W):
        sx = x - shift
        if 0 <= sx < W and img[sy][sx] and random.random() < 0.35 * fade + 0.05:
            ty = wl + ry
            if canvas[ty][x] == 0: canvas[ty][x] = REF

# ripples: dashed rings spreading from where the swan sits
for i, rx in enumerate((40, 52, 63)):
    ry_ = rx * 0.2
    for t in range(0, 3600):
        a = math.radians(t / 10)
        if math.sin(a) < -0.05: continue               # behind the swan stays clear
        if math.sin(a * (7 + i * 2) + i) < -0.2: continue   # dashes
        x = round(cx + rx * math.cos(a)); y = round(wl + 1 + ry_ * math.sin(a))
        if 0 <= x < W and 0 <= y < NH and canvas[y][x] != SW:
            canvas[y][x] = RIP

# encode: each cell takes the colour of its strongest layer (swan > ripple > reflection)
TAG = {SW: "$2", RIP: "$1", REF: "$3"}
outl = []
for cy in range(0, NH, 4):
    s, cur = "", None
    for ccx in range(CW):
        v, kinds = 0, {}
        for dx, dy, b in BITS:
            y, x = cy + dy, ccx*2 + dx
            if y < NH and canvas[y][x]:
                v |= b; k = canvas[y][x]; kinds[k] = kinds.get(k, 0) + 1
        if not v: s += " "; continue
        k = SW if SW in kinds else (RIP if RIP in kinds else REF)
        if TAG[k] != cur: s += TAG[k]; cur = TAG[k]
        s += chr(0x2800 + v)
    outl.append(s.rstrip())
while outl and not outl[-1].strip(): outl.pop()
open(out_txt, "w").write("\n".join(outl) + "\n")

col = {SW: (207,205,196), RIP: (127,166,110), REF: (98,99,94)}
ph = len(outl) * 4
with open(out_ppm, "w") as f:
    f.write(f"P3 {W} {ph} 255\n")
    for y in range(ph):
        f.write(" ".join("%d %d %d" % (col[canvas[y][x]] if y < NH and canvas[y][x] else (22,23,22)) for x in range(W)) + "\n")
print("rows", len(outl), "waterline", wl, "centre", cx)
