#!/bin/bash
# Kokemusu extras: apps Omarchy does not theme on its own.
#   ./install-extras.sh            install (each replaced file is backed up once)
#   ./install-extras.sh --remove   restore the backups
#
# Touches only colour/look files: GTK, starship, fastfetch, lazygit, yazi, cava, tmux,
# fish, Zed, opencode, Zen browser, the system font, the bar, clock and status icons
# (rebuilt from Omarchy's stock files plus a small patch), and the lock screen (a clone
# of omarchy.lock whose LockView.qml is replaced). It never needs sudo: fonts go to
# ~/.local/share/fonts. It never changes the cursor theme.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
extras="$here/extras"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
state="${XDG_STATE_HOME:-$HOME/.local/state}/kokemusu"
fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/kokemusu"
stock="${OMARCHY_PATH:-/usr/share/omarchy}/shell/plugins"
tag="pre-kokemusu"
mono_font="BlexMono Nerd Font"
nerd_fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/IBMPlexMono.tar.xz"

say() { printf '  \e[38;2;127;166;110m›\e[0m %s\n' "$1"; }
dim() { printf '  \e[38;2;98;99;94m· %s\e[0m\n' "$1"; }

# place <source> <target>: back the target up once, then copy the source over it
place() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e $dst && ! -e $dst.$tag ]] && ! cmp -s "$src" "$dst"; then
    cp -a "$dst" "$dst.$tag"
  fi
  cp "$src" "$dst"
  say "${dst/#$HOME/\~}"
}

restore() {
  local dst="$1"
  if [[ -e $dst.$tag ]]; then
    mv -f "$dst.$tag" "$dst"
    say "restored ${dst/#$HOME/\~}"
  fi
}

# backup <file>: keep the original once before editing a user's own config in place
backup() { [[ -e $1 && ! -e $1.$tag ]] && cp -a "$1" "$1.$tag"; return 0; }

widgets=(network bluetooth audio power monitor)

targets=(
  "$cfg/hypr/hyprland.lua"
  "$cfg/zed/themes/kokemusu.json"
  "$cfg/zed/settings.json"
  "$cfg/opencode/themes/kokemusu.json"
  "$cfg/opencode/tui.json"
  "$cfg/tmux/tmux.conf"
  "$cfg/cava/config"
  "$cfg/gtk-3.0/gtk.css"
  "$cfg/gtk-4.0/gtk.css"
  "$cfg/starship.toml"
  "$cfg/fastfetch/config.jsonc"
  "$cfg/fastfetch/kokemusu-logo.txt"
  "$cfg/yazi/theme.toml"
  "$cfg/cava/themes/kokemusu"
  "$cfg/tmux/kokemusu.conf"
  "$cfg/lazygit/config.yml"
  "$cfg/omarchy/plugins/$USER.lock/LockView.qml"
  "$cfg/omarchy/plugins/$USER.bar/Bar.qml"
  "$cfg/omarchy/plugins/$USER.clock/BarWidget.qml"
  "$cfg/omarchy/plugins/tornikegomareli.spaces/Spaces.qml"
)
for w in "${widgets[@]}"; do targets+=("$cfg/omarchy/plugins/$USER.$w/Panel.qml"); done

if [[ ${1:-} == --remove ]]; then
  for t in "${targets[@]}"; do restore "$t"; done
  for zen_root in "$HOME/.config/zen" "$HOME/.zen"; do
    [[ -f $zen_root/profiles.ini ]] || continue
    while IFS= read -r rel; do
      for f in userChrome.css userContent.css; do
        cf="$zen_root/$rel/chrome/$f"
        if [[ -e $cf.$tag ]]; then mv -f "$cf.$tag" "$cf"; say "restored ${cf/#$HOME/\~}"
        elif [[ -f $cf ]]; then sed -i '/kokemusu/d' "$cf"; say "cleaned ${cf/#$HOME/\~}"; fi
      done
    done < <(sed -n 's/^Path=//p' "$zen_root/profiles.ini")
  done
  rm -f "$cfg/hypr/kokemusu.lua" "$cfg/nvim/lua/plugins/kokemusu.lua"
  rm -f "$cfg/fish/conf.d/zzz-kokemusu.fish" "$cfg/fish/conf.d/zzz-kokemusu-tide.fish"
  for w in "${widgets[@]}"; do rm -f "$cfg/omarchy/plugins/$USER.$w/StoneIcon.qml"; done
  if [[ -f $state/previous-font ]] && command -v omarchy >/dev/null; then
    prev=$(<"$state/previous-font")
    [[ -n $prev ]] && omarchy font set "$prev" >/dev/null 2>&1 && say "font restored to $prev"
    rm -f "$state/previous-font"
  fi
  command -v omarchy >/dev/null && { omarchy restart shell >/dev/null 2>&1 || true; }
  dim "fonts in ${fonts_dir/#$HOME/\~} are left in place; delete that folder to remove them"
  exit 0
fi

echo
printf '  \e[38;2;207;205;196mKokemusu\e[0m \e[38;2;98;99;94mextras\e[0m\n\n'

# Fonts: Instrument Serif for the clock and lock screen ships with the theme (OFL).
# BlexMono Nerd Font (IBM Plex Mono with icons) is the system mono; it comes from the
# ttf-ibmplex-mono-nerd package if installed, or is downloaded from Nerd Fonts here.
mkdir -p "$fonts_dir"
cp "$extras"/fonts/*.ttf "$extras/fonts/OFL.txt" "$fonts_dir/"
if ! fc-list : family | grep -Fi "$mono_font" >/dev/null; then
  tmp=$(mktemp -d)
  if curl -fsSL "$nerd_fonts_url" -o "$tmp/plex.tar.xz" && tar -xJf "$tmp/plex.tar.xz" -C "$tmp"; then
    mkdir -p "$fonts_dir/BlexMono"
    find "$tmp" -name 'BlexMonoNerdFont-*.ttf' -exec cp {} "$fonts_dir/BlexMono/" \;
    find "$tmp" -iname 'LICENSE*' -exec cp {} "$fonts_dir/BlexMono/" \; 2>/dev/null || true
    say "${fonts_dir/#$HOME/\~}/BlexMono"
  else
    dim "could not download BlexMono; install it with: omarchy pkg add ttf-ibmplex-mono-nerd"
  fi
  rm -rf "$tmp"
fi
fc-cache -f "$fonts_dir" >/dev/null 2>&1 || true
say "${fonts_dir/#$HOME/\~} (Instrument Serif)"

if command -v omarchy >/dev/null && fc-list : family | grep -Fi "$mono_font" >/dev/null; then
  current_font=$(omarchy font current 2>/dev/null || true)
  mkdir -p "$state"
  if [[ ! -f $state/previous-font && -n $current_font && $current_font != "$mono_font" ]]; then
    printf '%s' "$current_font" >"$state/previous-font"
  fi
  if [[ $current_font != "$mono_font" ]]; then
    omarchy font set "$mono_font" >/dev/null 2>&1 || true
    [[ $(omarchy font current 2>/dev/null) == "$mono_font" ]] && say "system font: $mono_font" || dim "could not set the font; run: omarchy font set \"$mono_font\""
  fi
fi

place "$extras/gtk.css" "$cfg/gtk-3.0/gtk.css"
place "$extras/gtk.css" "$cfg/gtk-4.0/gtk.css"

command -v starship >/dev/null && place "$extras/starship.toml" "$cfg/starship.toml" || dim "starship not installed"

if command -v fastfetch >/dev/null; then
  place "$extras/fastfetch/config.jsonc" "$cfg/fastfetch/config.jsonc"
  place "$extras/fastfetch/logo.txt" "$cfg/fastfetch/kokemusu-logo.txt"
else
  dim "fastfetch not installed"
fi

command -v yazi >/dev/null && place "$extras/yazi-theme.toml" "$cfg/yazi/theme.toml" || dim "yazi not installed"

if command -v cava >/dev/null; then
  place "$extras/cava-theme" "$cfg/cava/themes/kokemusu"
else
  dim "cava not installed"
fi

command -v tmux >/dev/null && place "$extras/tmux.conf" "$cfg/tmux/kokemusu.conf"

# Hyprland motion and Neovim colours: a GitHub install drops the theme's .lua files,
# so load them from the installed theme while Kokemusu is active.
if [[ -f $cfg/hypr/hyprland.lua ]]; then
  place "$extras/hypr/kokemusu.lua" "$cfg/hypr/kokemusu.lua"
  hl="$cfg/hypr/hyprland.lua"
  if ! grep -q 'require("hypr.kokemusu")' "$hl"; then
    backup "$hl"
    printf '\nrequire("hypr.kokemusu") -- Kokemusu theme motion (install-extras.sh)\n' >>"$hl"
    say "${hl/#$HOME/\~} (loads hypr/kokemusu.lua)"
  fi
  hyprctl reload >/dev/null 2>&1 || true
fi
[[ -d $cfg/nvim/lua/plugins ]] && place "$extras/nvim/kokemusu.lua" "$cfg/nvim/lua/plugins/kokemusu.lua"

# fish: syntax, autosuggestion, pager and Tide colours (only while Kokemusu is active)
if command -v fish >/dev/null; then
  place "$extras/fish/zzz-kokemusu.fish" "$cfg/fish/conf.d/zzz-kokemusu.fish"
  place "$extras/fish/zzz-kokemusu-tide.fish" "$cfg/fish/conf.d/zzz-kokemusu-tide.fish"
fi

# Zed: install the theme and select it for dark mode
if [[ -d $cfg/zed ]]; then
  place "$extras/zed/kokemusu.json" "$cfg/zed/themes/kokemusu.json"
  zs="$cfg/zed/settings.json"
  [[ -f $zs ]] || echo '{}' >"$zs"
  backup "$zs"
  python3 - "$zs" <<'PY'
import re, sys
p = sys.argv[1]; s = open(p).read()
block = re.search(r'"theme"\s*:\s*\{[^{}]*\}', s)
if block:
    inner = block.group(0)
    new = re.sub(r'"dark"\s*:\s*"[^"]*"', '"dark": "Kokemusu"', inner)
    if '"dark"' not in new:
        new = new[:-1].rstrip().rstrip(',') + ',\n    "dark": "Kokemusu"\n  }'
    s = s.replace(inner, new)
elif re.search(r'"theme"\s*:\s*"[^"]*"', s):
    s = re.sub(r'"theme"\s*:\s*"[^"]*"', '"theme": "Kokemusu"', s, count=1)
else:
    s = re.sub(r'\{', '{\n  "theme": "Kokemusu",', s, count=1)
open(p, "w").write(s)
PY
  say "${zs/#$HOME/\~} (theme)"
fi

# opencode: install the theme and select it
if [[ -d $cfg/opencode ]]; then
  place "$extras/opencode/kokemusu.json" "$cfg/opencode/themes/kokemusu.json"
  tui="$cfg/opencode/tui.json"
  [[ -f $tui ]] || echo '{"$schema": "https://opencode.ai/tui.json"}' >"$tui"
  backup "$tui"
  python3 - "$tui" <<'PY'
import json, sys
p = sys.argv[1]; d = json.load(open(p)); d["theme"] = "kokemusu"
open(p, "w").write(json.dumps(d, indent=2) + "\n")
PY
  say "${tui/#$HOME/\~} (theme)"
fi

# Zen browser: import the theme from userChrome/userContent in every profile. Only one
# theme's import can win, so imports of the author's other theme (Tsukiyo) are dropped.
for zen_root in "$HOME/.config/zen" "$HOME/.zen"; do
  [[ -f $zen_root/profiles.ini ]] || continue
  while IFS= read -r rel; do
    prof="$zen_root/$rel"
    [[ -d $prof ]] || continue
    mkdir -p "$prof/chrome"
    cp "$extras/zen/kokemusu.css" "$prof/chrome/kokemusu.css"
    cp "$extras/zen/kokemusu-content.css" "$prof/chrome/kokemusu-content.css"
    for pair in "userChrome.css:kokemusu.css" "userContent.css:kokemusu-content.css"; do
      f="$prof/chrome/${pair%%:*}"; imp="@import url(\"${pair##*:}\");"
      touch "$f"
      if ! grep -qF "$imp" "$f"; then
        backup "$f"
        sed -i '/@import url("tsukiyo/d' "$f"
        printf '%s\n%s' "$imp" "$(cat "$f")" >"$f"
      fi
    done
    grep -q legacyUserProfileCustomizations "$prof/user.js" 2>/dev/null ||
      echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >>"$prof/user.js"
    say "${prof/#$HOME/\~} (restart Zen)"
  done < <(sed -n 's/^Path=//p' "$zen_root/profiles.ini")
done

# tmux: source the theme last so it wins over earlier colour settings
if command -v tmux >/dev/null; then
  tc="$cfg/tmux/tmux.conf"; [[ -f $tc ]] || tc="$HOME/.tmux.conf"
  line="source-file $cfg/tmux/kokemusu.conf"
  if [[ -f $tc ]] && ! grep -qF "$line" "$tc"; then
    backup "$tc"
    sed -i '/tsukiyo\.conf/d;/^# Tsukiyo$/d' "$tc"
    printf '\n# Kokemusu\n%s\n' "$line" >>"$tc"
    say "${tc/#$HOME/\~} (sources kokemusu.conf)"
    tmux source-file "$tc" 2>/dev/null || true
  fi
fi

# cava: write a flat colour into [color], replacing any earlier theme block
cc="$cfg/cava/config"
if command -v cava >/dev/null && [[ -f $cc ]] && ! grep -q "kokemusu begin" "$cc"; then
  backup "$cc"
  python3 - "$cc" "$extras/cava-theme" <<'PY'
import re, sys
cfg, theme = sys.argv[1], sys.argv[2]
lines = [l for l in open(theme).read().splitlines() if l and not l.startswith(("#", "["))]
block = "# kokemusu begin\n" + "\n".join(lines) + "\n# kokemusu end\n"
s = open(cfg).read()
s = re.sub(r"# (tsukiyo|kokemusu) begin\n.*?# \1 end\n", "", s, flags=re.S)
s = s.replace("[color]\n", "[color]\n" + block, 1) if "[color]\n" in s else s + "\n[color]\n" + block
open(cfg, "w").write(s)
PY
  say "${cc/#$HOME/\~} (flat moss)"
fi

# lazygit: merge the gui.theme block instead of replacing the user's config
if command -v lazygit >/dev/null; then
  lg="$cfg/lazygit/config.yml"
  mkdir -p "$(dirname "$lg")"
  touch "$lg"
  backup "$lg"
  python3 - "$lg" "$extras/lazygit.yml" <<'PY'
import sys, re
target, theme = sys.argv[1], sys.argv[2]
text = open(target).read()
block = open(theme).read().split("\n", 1)[1]  # drop the comment line
text = re.sub(r"(?ms)^gui:\n(?:[ \t]+.*\n?|\n)*", "", text).rstrip()
open(target, "w").write((text + "\n\n" if text else "") + block)
PY
  say "${lg/#$HOME/\~} (gui block)"
fi

# Shell: each file is rebuilt from Omarchy's stock copy and then patched, so the
# result is the same whether or not another theme patched the clone before.
shell_patch() {
  local source_id="$1" stock_file="$2" file="$3" patch_file="$4"
  local dir="$cfg/omarchy/plugins/$USER.${source_id#omarchy.}"
  [[ -d $dir ]] || omarchy plugin clone "$source_id" >/dev/null
  if [[ ! -f $dir/$file ]]; then
    dim "could not clone $source_id"
    return
  fi
  local tmp; tmp=$(mktemp)
  cp "$stock_file" "$tmp"
  if patch -s "$tmp" "$patch_file" >/dev/null 2>&1; then
    if ! cmp -s "$tmp" "$dir/$file"; then
      [[ -e $dir/$file.$tag ]] || cp -a "$dir/$file" "$dir/$file.$tag"
      cp "$tmp" "$dir/$file"
    fi
    say "${dir/#$HOME/\~}/$file"
  else
    dim "$source_id changed upstream; patch skipped"
  fi
  rm -f "$tmp" "$tmp.orig" "$tmp.rej"
}

if command -v omarchy >/dev/null; then
  shell_patch omarchy.bar "$stock/bar/Bar.qml" Bar.qml "$extras/shell/bar.patch"
  shell_patch omarchy.clock "$stock/panels/clock/BarWidget.qml" BarWidget.qml "$extras/shell/clock.patch"
  # Hairline icons: each status widget keeps its logic and draws StoneIcon.
  for w in "${widgets[@]}"; do
    shell_patch "omarchy.$w" "$stock/panels/$w/Panel.qml" Panel.qml "$extras/shell/$w.patch"
    [[ -d $cfg/omarchy/plugins/$USER.$w ]] && cp "$extras/shell/StoneIcon.qml" "$cfg/omarchy/plugins/$USER.$w/StoneIcon.qml"
  done
  # tornikegomareli.spaces (third-party workspace widget), if installed: its "accent"
  # style becomes a dim moss wash with a moss number instead of a solid block.
  spaces_dir="$cfg/omarchy/plugins/tornikegomareli.spaces"
  if [[ -f $spaces_dir/Spaces.qml ]] && ! grep -q "Kokemusu" "$spaces_dir/Spaces.qml"; then
    if patch -s --dry-run "$spaces_dir/Spaces.qml" "$extras/shell/spaces.patch" >/dev/null 2>&1; then
      [[ -e $spaces_dir/Spaces.qml.$tag ]] || cp -a "$spaces_dir/Spaces.qml" "$spaces_dir/Spaces.qml.$tag"
      patch -s "$spaces_dir/Spaces.qml" "$extras/shell/spaces.patch"
      say "${spaces_dir/#$HOME/\~}/Spaces.qml (set Active style to Accent)"
    else
      dim "tornikegomareli.spaces changed upstream; patch skipped"
    fi
  fi

  if command -v jq >/dev/null && [[ -f $cfg/omarchy/shell.json ]]; then
    tmp=$(mktemp)
    jq '(.bar.centerAnchor) |= (if . == "omarchy.clock" then env.USER + ".clock" else . end)' "$cfg/omarchy/shell.json" >"$tmp" && mv "$tmp" "$cfg/omarchy/shell.json"
  fi
fi

# Lock screen: clone the stock lock plugin once, then swap in the Kokemusu view.
# Service.qml (password and fingerprint handling) stays Omarchy's own.
if command -v omarchy >/dev/null; then
  lock_dir="$cfg/omarchy/plugins/$USER.lock"
  [[ -d $lock_dir ]] || omarchy plugin clone omarchy.lock >/dev/null
  if [[ -f $lock_dir/LockView.qml ]]; then
    place "$extras/lock/LockView.qml" "$lock_dir/LockView.qml"
    dim "lock screen: preview it with  omarchy-shell lock preview  (click to close)"
  else
    dim "lock screen: could not clone omarchy.lock"
  fi
  omarchy restart shell >/dev/null 2>&1 || true
fi

echo
dim "undo with ./install-extras.sh --remove"
echo
