-- Kokemusu for Neovim, built on tokyonight's highlight coverage.
-- Philosophy: text is faded paper, structure is grey stone, moss is spent sparingly.
-- Keywords and functions carry the hue; punctuation, comments and chrome recede.
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      dim_inactive = false,
      lualine_bold = false,

      on_colors = function(c)
        -- Surfaces: faded charcoal, one step apart each
        c.bg = "#161716"
        c.bg_dark = "#121312"
        c.bg_dark1 = "#0e0f0e"
        c.bg_float = "#121312"
        c.bg_sidebar = "#121312"
        c.bg_popup = "#121312"
        c.bg_statusline = "#121312"
        c.bg_highlight = "#1e1f1e"
        c.bg_visual = "#2d3a2f"
        c.bg_search = "#33372f"

        -- Text
        c.fg = "#cfcdc4"
        c.fg_dark = "#b5b3aa"
        c.fg_float = "#cfcdc4"
        c.fg_sidebar = "#b5b3aa"
        c.fg_gutter = "#363734"
        c.comment = "#6e6f69"
        c.dark3 = "#62635e"
        c.dark5 = "#7c7d77"
        c.terminal_black = "#2d3a2f"
        c.border = "#1e1f1e"
        c.border_highlight = "#62635e"

        -- Hue, all at the same low saturation
        c.blue = "#869fae"
        c.blue0 = "#2d3a2f"
        c.blue1 = "#7fa66e"
        c.blue2 = "#88aea7"
        c.blue5 = "#97afbd"
        c.blue6 = "#b4c6cf"
        c.blue7 = "#33372f"
        c.cyan = "#88aea7"
        c.teal = "#88aea7"
        c.green = "#7fa66e"
        c.green1 = "#7fa66e"
        c.green2 = "#6e8f62"
        c.yellow = "#d6bd8a"
        c.orange = "#d4a185"
        c.red = "#c98378"
        c.red1 = "#c98378"
        c.magenta = "#a798b0"
        c.magenta2 = "#b6a8bf"
        c.purple = "#a798b0"

        c.git = { add = "#6e8f62", change = "#7690a0", delete = "#a96c63" }
        c.diff = { add = "#1c241b", change = "#1b1f22", delete = "#271c1b", text = "#2a302b" }
        c.error = "#c98378"
        c.warning = "#d6bd8a"
        c.info = "#869fae"
        c.hint = "#88aea7"
      end,

      on_highlights = function(hl, c)
        local moss = "#7fa66e"
        local stone = "#2a2b29"

        -- Editor chrome: nearly invisible until you need it
        hl.LineNr = { fg = "#363734" }
        hl.LineNrAbove = { fg = "#363734" }
        hl.LineNrBelow = { fg = "#363734" }
        hl.CursorLineNr = { fg = moss }
        hl.CursorLine = { bg = "#1b1c1b" }
        hl.SignColumn = { bg = c.bg }
        hl.WinSeparator = { fg = "#1e1f1e" }
        hl.VertSplit = { fg = "#1e1f1e" }
        hl.EndOfBuffer = { fg = c.bg }
        hl.NonText = { fg = "#363734" }
        hl.Whitespace = { fg = "#212220" }
        hl.MatchParen = { fg = c.yellow, bold = true }
        hl.Visual = { bg = "#2d3a2f" }
        hl.Search = { bg = "#33372f", fg = c.fg }
        hl.IncSearch = { bg = moss, fg = c.bg }
        hl.CurSearch = { bg = moss, fg = c.bg }

        -- Floats and popups share one framed look
        hl.NormalFloat = { bg = c.bg_float, fg = c.fg }
        hl.FloatBorder = { bg = c.bg_float, fg = "#363734" }
        hl.FloatTitle = { bg = c.bg_float, fg = moss }
        hl.Pmenu = { bg = c.bg_float, fg = c.fg_dark }
        hl.PmenuSel = { bg = "#2d3a2f", fg = c.fg }
        hl.PmenuSbar = { bg = c.bg_float }
        hl.PmenuThumb = { bg = "#363734" }

        -- Syntax
        hl.Comment = { fg = c.comment, italic = true }
        hl["@comment"] = { link = "Comment" }
        hl["@punctuation.bracket"] = { fg = "#8f8e87" }
        hl["@punctuation.delimiter"] = { fg = "#7c7d77" }
        hl["@operator"] = { fg = "#8f8e87" }
        hl["@keyword"] = { fg = c.magenta }
        hl["@keyword.function"] = { fg = c.magenta }
        hl["@keyword.return"] = { fg = c.magenta }
        hl["@function"] = { fg = c.blue }
        hl["@function.call"] = { fg = c.blue }
        hl["@function.method.call"] = { fg = c.blue }
        hl["@variable"] = { fg = c.fg }
        hl["@variable.member"] = { fg = "#b5b3aa" }
        hl["@property"] = { fg = "#b5b3aa" }
        hl["@variable.parameter"] = { fg = "#d0bfa8", italic = true }
        hl["@type"] = { fg = c.cyan }
        hl["@type.builtin"] = { fg = c.cyan }
        hl["@constant"] = { fg = c.orange }
        hl["@constant.builtin"] = { fg = c.orange }
        hl["@number"] = { fg = c.orange }
        hl["@boolean"] = { fg = c.orange }
        hl["@string"] = { fg = c.green }
        hl["@string.escape"] = { fg = c.cyan }
        hl["@tag"] = { fg = c.blue }
        hl["@tag.attribute"] = { fg = c.cyan, italic = true }
        hl["@tag.delimiter"] = { fg = "#7c7d77" }
        hl["@markup.heading"] = { fg = moss, bold = true }
        hl["@markup.link"] = { fg = c.cyan, underline = true }

        -- Diagnostics: soft undercurls, tinted virtual text
        hl.DiagnosticVirtualTextError = { fg = c.red, bg = "#221b1a" }
        hl.DiagnosticVirtualTextWarn = { fg = c.yellow, bg = "#211f1a" }
        hl.DiagnosticVirtualTextInfo = { fg = c.blue, bg = "#191d20" }
        hl.DiagnosticVirtualTextHint = { fg = c.cyan, bg = "#192020" }

        -- File trees and pickers
        hl.Directory = { fg = c.blue }
        hl.SnacksPickerDir = { fg = c.comment }
        hl.SnacksPickerFile = { fg = c.fg }
        hl.SnacksPickerMatch = { fg = moss, bold = true }
        hl.SnacksPickerPrompt = { fg = moss }
        hl.SnacksPickerTitle = { fg = moss, bg = c.bg_float, bold = true }
        hl.SnacksPickerBorder = { fg = "#363734", bg = c.bg_float }
        hl.SnacksExplorerDirectory = { fg = c.blue }
        hl.SnacksIndent = { fg = "#212220" }
        hl.SnacksIndentScope = { fg = "#3a3b38" }
        hl.SnacksDashboardHeader = { fg = moss }
        hl.SnacksDashboardKey = { fg = c.yellow }
        hl.SnacksDashboardIcon = { fg = c.blue }
        hl.SnacksDashboardDesc = { fg = c.fg_dark }
        hl.SnacksDashboardFooter = { fg = c.comment, italic = true }
        hl.NeoTreeDirectoryName = { fg = c.blue }
        hl.NeoTreeDirectoryIcon = { fg = c.blue }
        hl.NeoTreeRootName = { fg = moss, bold = true }
        hl.NvimTreeFolderName = { fg = c.blue }
        hl.NvimTreeFolderIcon = { fg = c.blue }
        hl.TelescopeBorder = { fg = "#363734", bg = c.bg_float }
        hl.TelescopeMatching = { fg = moss, bold = true }
        hl.TelescopeSelection = { bg = "#2d3a2f", fg = c.fg }
        hl.TelescopePromptTitle = { fg = moss, bg = c.bg_float, bold = true }
        hl.MiniFilesTitleFocused = { fg = moss, bold = true }
        hl.MiniIndentscopeSymbol = { fg = "#3a3b38" }
        hl.IblIndent = { fg = "#212220" }
        hl.IblScope = { fg = "#3a3b38" }

        -- Completion menu kinds stay in the same quiet family
        hl.BlinkCmpMenuBorder = { fg = "#363734", bg = c.bg_float }
        hl.BlinkCmpDocBorder = { fg = "#363734", bg = c.bg_float }
        hl.BlinkCmpLabelMatch = { fg = moss, bold = true }

        -- Which-key, noice, notify
        hl.WhichKey = { fg = moss }
        hl.WhichKeyGroup = { fg = c.blue }
        hl.WhichKeyDesc = { fg = c.fg_dark }
        hl.WhichKeySeparator = { fg = "#62635e" }
        hl.NoiceCmdlinePopupBorder = { fg = "#363734" }
        hl.NoiceCmdlineIcon = { fg = moss }

        -- Statusline: the mode sits on a stone block in moss text, no loud fill
        hl.lualine_a_normal = { fg = moss, bg = stone, bold = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
