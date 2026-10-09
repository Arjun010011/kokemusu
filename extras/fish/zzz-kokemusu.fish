# Kokemusu for fish: paper commands, quiet punctuation, moss for what matters.
# install-extras.sh copies this to ~/.config/fish/conf.d/. Named zzz- so it loads after
# other themes' colour files.
# Global (not universal) variables: removing the file restores your previous colors.

status is-interactive; or exit
# Only while Kokemusu is the active Omarchy theme, so other themes' files win otherwise.
test (cat ~/.local/state/omarchy/current/theme.name 2>/dev/null) = kokemusu; or exit

set -g fish_color_normal cfcdc4
set -g fish_color_command e0ded5 --bold
set -g fish_color_keyword a798b0
set -g fish_color_quote 7fa66e
set -g fish_color_redirection 88aea7
set -g fish_color_end 7c7d77
set -g fish_color_error c98378
set -g fish_color_param cfcdc4
set -g fish_color_valid_path --underline
set -g fish_color_option b5b3aa
set -g fish_color_comment 6e6f69 --italics
set -g fish_color_operator 88aea7
set -g fish_color_escape 88aea7
set -g fish_color_autosuggestion 62635e
set -g fish_color_selection --background=2d3a2f
set -g fish_color_search_match --background=33372f
set -g fish_color_history_current --bold
set -g fish_color_cancel c98378 --reverse
set -g fish_color_cwd 7fa66e
set -g fish_color_cwd_root c98378
set -g fish_color_user a7b89c
set -g fish_color_host 7fa66e
set -g fish_color_host_remote d6bd8a
set -g fish_color_status c98378

set -g fish_pager_color_progress 7c7d77
set -g fish_pager_color_prefix 7fa66e --bold
set -g fish_pager_color_completion cfcdc4
set -g fish_pager_color_description 7c7d77 --italics
set -g fish_pager_color_selected_background --background=2d3a2f
set -g fish_pager_color_selected_prefix 7fa66e --bold
set -g fish_pager_color_selected_completion e0ded5
set -g fish_pager_color_selected_description a7b89c
