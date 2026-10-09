# Kokemusu for the Tide prompt.
# Tide renders the prompt in a background fish process that reads universal
# variables, and every open shell repaints from them. So this file writes each
# colour only when it differs: a new shell never flips the colours under the
# shells that are already open. Named zzz- so it runs after other conf.d files.
#
# While another theme is active it hands Tide's colours back as Catppuccin
# Mocha defaults (the values most Tide colour files expect to translate), then
# does nothing more. Delete this file to stop it.

status is-interactive; or exit
set -q tide_left_prompt_items; or exit

set -l active (cat ~/.local/state/omarchy/current/theme.name 2>/dev/null)

set -l kokemusu \
    prompt_color_separator_same_color:62635e \
    pwd_bg_color:2a2b29 pwd_color_dirs:9a9890 pwd_color_anchors:e0ded5 pwd_color_truncated_dirs:62635e \
    git_bg_color:2a2b29 git_bg_color_unstable:2a2b29 git_bg_color_urgent:2a2b29 \
    git_color_branch:7fa66e git_color_dirty:d6bd8a git_color_staged:7fa66e git_color_untracked:869fae \
    git_color_upstream:cfcdc4 git_color_stash:a798b0 git_color_conflicted:c98378 git_color_operation:c98378 \
    character_color:7fa66e character_color_failure:c98378 \
    cmd_duration_color:7c7d77 python_color:88aea7 node_color:7fa66e go_color:869fae rustc_color:d4a185 \
    status_color:7fa66e status_color_failure:c98378 jobs_color:7fa66e

# Catppuccin Mocha values from the stock pill prompt, restored for other themes.
set -l mocha \
    prompt_color_separator_same_color:6c7086 \
    pwd_bg_color:313244 pwd_color_dirs:89b4fa pwd_color_anchors:b4befe pwd_color_truncated_dirs:9399b2 \
    git_bg_color:89b4fa git_bg_color_unstable:f9e2af git_bg_color_urgent:f38ba8 \
    git_color_branch:11111b git_color_dirty:11111b git_color_staged:11111b git_color_untracked:11111b \
    git_color_upstream:11111b git_color_stash:11111b git_color_conflicted:11111b git_color_operation:11111b \
    character_color:cba6f7 character_color_failure:f38ba8

if test "$active" = kokemusu
    for pair in $kokemusu
        set -l kv (string split : -- $pair)
        set -l var tide_$kv[1]
        test "$$var" = "$kv[2]"; or set -U $var $kv[2]
    end
else
    # Only undo values that are still exactly Kokemusu's.
    for pair in $mocha
        set -l kv (string split : -- $pair)
        set -l var tide_$kv[1]
        for own in $kokemusu
            set -l ok (string split : -- $own)
            if test "$ok[1]" = "$kv[1]" -a "$$var" = "$ok[2]"
                set -U $var $kv[2]
            end
        end
    end
end
