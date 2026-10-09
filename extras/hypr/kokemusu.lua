-- Kokemusu motion loader, installed by install-extras.sh as ~/.config/hypr/kokemusu.lua.
-- `omarchy theme install` drops a cloned theme's hyprland.lua, so the theme's
-- animations, dimming and blur rules would be lost. This loads that file from the
-- installed theme, but only while Kokemusu is the active theme: switch themes and
-- it does nothing. Remove the require("hypr.kokemusu") line to turn it off.
local home = os.getenv("HOME") or ""
local f = io.open(home .. "/.local/state/omarchy/current/theme.name")
local name = f and f:read("*l") or ""
if f then f:close() end

if name == "kokemusu" then
  pcall(dofile, home .. "/.config/omarchy/themes/kokemusu/hyprland.lua")
end
