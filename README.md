<div align="center">

# 苔むす · Kokemusu

<p><a href="#install"><img src="https://img.shields.io/badge/Omarchy-theme-7fa66e?style=flat-square&labelColor=161716" alt="Omarchy theme"></a>&nbsp;<a href="#palette"><img src="https://img.shields.io/badge/palette-faded_black_%2B_moss-6e6f69?style=flat-square&labelColor=161716" alt="faded black and moss"></a>&nbsp;<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-cfcdc4?style=flat-square&labelColor=161716" alt="MIT license"></a></p>

<b>苔むした石に、静かな夕暮れを。</b><br>
<sub><i>A quiet dusk on moss-covered stone.</i></sub>

*Kokemusu* (苔むす) means "to become covered in moss", the way old stone slowly turns green.
Faded, nearly neutral blacks, paper-coloured text, plain grey borders, and moss green kept
for the few things that should catch your eye. Flat colour everywhere: no gradients.

```bash
omarchy theme install https://github.com/Arjun010011/kokemusu
```

</div>

## Palette

| | Role | Hex |
|:-:|---|---|
| ![](https://img.shields.io/badge/-%20%20%20-161716?style=flat-square) | Background, faded charcoal | `#161716` |
| ![](https://img.shields.io/badge/-%20%20%20-1e1f1e?style=flat-square) | Raised surface | `#1e1f1e` |
| ![](https://img.shields.io/badge/-%20%20%20-6e6f69?style=flat-square) | Border, focused window | `#6e6f69` |
| ![](https://img.shields.io/badge/-%20%20%20-cfcdc4?style=flat-square) | Text, faded paper | `#cfcdc4` |
| ![](https://img.shields.io/badge/-%20%20%20-7fa66e?style=flat-square) | Moss, the accent | `#7fa66e` |
| ![](https://img.shields.io/badge/-%20%20%20-d4a185?style=flat-square) | Peach, the one warm note | `#d4a185` |
| ![](https://img.shields.io/badge/-%20%20%20-c98378?style=flat-square) | Rust, errors | `#c98378` |
| ![](https://img.shields.io/badge/-%20%20%20-d6bd8a?style=flat-square) | Straw | `#d6bd8a` |
| ![](https://img.shields.io/badge/-%20%20%20-88aea7?style=flat-square) | Lichen cyan | `#88aea7` |
| ![](https://img.shields.io/badge/-%20%20%20-869fae?style=flat-square) | Creek blue | `#869fae` |
| ![](https://img.shields.io/badge/-%20%20%20-a798b0?style=flat-square) | Heather | `#a798b0` |

**Rules the theme follows:** greys and green never blend into each other; borders and focus
rings are grey; green appears only on small signals (active workspace, switches that are on,
prompts, the cpu meter); every surface and meter is one flat colour.

## What's inside

| Part | What it does |
|---|---|
| **Bar** | One flat full-width charcoal strip with a grey hairline that turns faintly moss on hover. Hand-drawn hairline icons for Wi-Fi, Bluetooth, volume, display and battery. If you use the [Spaces](https://github.com/tornikegomareli/omarchy-spaces) workspace widget, its Accent style becomes a dim moss wash with a moss number. |
| **Clock** | Lowercase weekday in the mono font, the time in Instrument Serif, an italic meridiem. |
| **Lock screen** | The wallpaper under one flat veil, a large serif time set low on the left, 苔むす in the corner, and a solid password card with a grey border. Moss shows only as one small dot. |
| **btop** | Grey boxes, one flat colour per meter: moss cpu, lichen memory, creek download, peach upload and temperature. |
| **Terminals** | Alacritty, Ghostty, Kitty and Foot, with matching padding and a beam cursor. |
| **Motion** | Windows rise a little as they open, workspaces slide and fade, unfocused windows dim slightly, solid borders. |
| **Apps** | Neovim, Zed, opencode, Zen browser, GTK 3/4, fish and Tide, tmux, starship, fastfetch (a portrait traced in moss, with the system in small trees), eza (moss folders), lazygit, yazi, cava. |
| **Fonts** | BlexMono Nerd Font (IBM Plex Mono) for the system, Instrument Serif for the clock and lock screen. |
| **Wallpapers** | Nine 4K greenery photos: foggy laurel forest, ferns, moss, sunlit beech, a mossy stream, tea hills and misty karst peaks. |

## Install

**1. The theme.** Everything Omarchy themes itself: Hyprland borders, the shell, terminals,
btop, Neovim, Chromium and more.

```bash
omarchy theme install https://github.com/Arjun010011/kokemusu
```

**2. The extras (optional).** The bar, clock, icons, lock screen, fonts and the apps Omarchy
does not theme. Every file it replaces is backed up once, and nothing needs sudo.

```bash
~/.config/omarchy/themes/kokemusu/install-extras.sh
```

Undo the extras with `install-extras.sh --remove`. That restores your backups and your
previous system font.

> A theme installed from GitHub cannot ship Lua or terminal configs, so Omarchy generates
> those from `colors.toml`. `install-extras.sh` loads the theme's own Hyprland motion and
> Neovim colours while Kokemusu is active.

## Credits

- Wallpapers: Wikimedia Commons photographers, listed with licences in
  [`backgrounds/CREDITS.md`](backgrounds/CREDITS.md).
- [Instrument Serif](https://github.com/Instrument/instrument-serif), SIL Open Font License
  ([`extras/fonts/OFL.txt`](extras/fonts/OFL.txt)).
- [IBM Plex Mono](https://github.com/IBM/plex) via [Nerd Fonts](https://www.nerdfonts.com/),
  downloaded at install time.
- Sibling theme: [Tsukiyo](https://github.com/Arjun010011/omarchy-tsukiyo-theme).

The theme's code and configs are MIT licensed. Wallpapers and fonts keep their own licences.
