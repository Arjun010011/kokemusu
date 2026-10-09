-- Kokemusu colours for Neovim, installed by install-extras.sh into lua/plugins/.
-- `omarchy theme install` replaces a cloned theme's neovim.lua with a generic
-- palette scheme; this loads the hand-tuned one from the installed theme instead,
-- but only while Kokemusu is the active theme. Delete this file to turn it off.
local f = io.open(vim.fn.expand("~/.local/state/omarchy/current/theme.name"))
local name = f and f:read("*l") or ""
if f then f:close() end
if name ~= "kokemusu" then return {} end

local ok, spec = pcall(dofile, vim.fn.expand("~/.config/omarchy/themes/kokemusu/neovim.lua"))
return ok and spec or {}
