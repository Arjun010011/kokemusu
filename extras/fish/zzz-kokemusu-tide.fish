# Kokemusu for the Tide prompt.
# Tide renders from universal variables, so this recolours them in place. It
# only translates known Catppuccin Mocha values (Tide's most common palette) and
# Tsukiyo's values to their Kokemusu counterparts, so any prompt layout keeps
# working. Named zzz- so it runs after other conf.d files that set Tide's colours.
# Delete this file (and restart fish) to let those files restore their colours.

status is-interactive; or exit
# Only while Kokemusu is the active Omarchy theme, so other themes' files win otherwise.
test (cat ~/.local/state/omarchy/current/theme.name 2>/dev/null) = kokemusu; or exit
set -q tide_left_prompt_items; or exit

set -l kokemusu_map \
    313244:2a2b29 45475a:2c2d2b 585b70:62635e 1e1e2e:161716 181825:121312 11111b:161716 \
    89b4fa:7fa66e b4befe:cfcdc4 9399b2:7c7d77 cba6f7:7fa66e f38ba8:c98378 eba0ac:c98378 \
    f9e2af:d6bd8a a6e3a1:7fa66e 6c7086:62635e 7f849c:6e6f69 fab387:d4a185 94e2d5:88aea7 \
    74c7ec:869fae 89dceb:88aea7 f5c2e7:a798b0 f2cdcd:d0bfa8 cdd6f4:cfcdc4 bac2de:b5b3aa \
    a6adc8:a7b89c f5e0dc:e0ded5 1f2c2b:2a2b29 28323a:2c2d2b 4a5a63:62635e 121820:161716 \
    0e1319:121312 88a4ad:7fa66e c8c4bb:cfcdc4 6a7175:7c7d77 b37a72:c98378 c4b48a:d6bd8a \
    8ca483:7fa66e 5f6e76:6e6f69 b8977a:d4a185 7fa3a3:88aea7 7a98ab:869fae 9c8898:a798b0 \
    c8b9a4:d0bfa8 b3b0a8:b5b3aa 9db4ad:a7b89c d8d4cc:e0ded5

for var in (set -U --names | string match 'tide_*color*')
    set -l value (string lower -- $$var)
    for pair in $kokemusu_map
        set -l kv (string split : -- $pair)
        if test "$value" = "$kv[1]"
            set -U $var $kv[2]
            break
        end
    end
end

# The git pill: stone background with coloured text, so green stays a small accent.
for pair in git_bg_color:2a2b29 git_bg_color_unstable:2a2b29 git_bg_color_urgent:2a2b29 \
    git_color_branch:7fa66e git_color_dirty:d6bd8a git_color_staged:7fa66e \
    git_color_untracked:869fae git_color_upstream:cfcdc4 git_color_stash:a798b0 \
    git_color_conflicted:c98378 git_color_operation:c98378
    set -l kv (string split : -- $pair)
    set -l var tide_$kv[1]
    test "$$var" = "$kv[2]"; or set -U $var $kv[2]
end
