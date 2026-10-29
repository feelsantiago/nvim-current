local utils = require("config.utils")

return {
  -- ── Colorscheme (loads first) ────────────────────────────────────────────
  -- {
  --   "shaunsingh/nord.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     vim.g.nord_contrast = true
  --     vim.g.nord_borders = true
  --     vim.g.nord_italic = false
  --     vim.g.nord_bold = true
  --     vim.g.nord_disable_background = true
  --     vim.g.nord_uniform_diff_background = true
  --
  --     vim.cmd("colorscheme nord")
  --   end,
  -- },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        -- hide_fillchars = true,
        terminal_colors = false,
        -- `cache = true` applies precompiled highlights during plugin load, but
        -- in some startup orderings the buffer isn't repainted with them until a
        -- redraw is forced (e.g. `:e`), so the theme appears "missing" on open.
        cache = false,
        borderless_pickers = false,
        variant = "auto",
      })

      vim.cmd("colorscheme cyberdream")
    end,
  },

  -- ── Icons ─────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Notifications ──────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    lazy = true,
    opts = {
      background_colour = "#000000",
      render = "compact",
      stages = "fade",
    },
  },

  -- ── Noice ───────────────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        hover = { silent = true },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = { event = "msg_show", find = "%d+ written" },
          opts = { skip = true },
        },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      cmdline = {
        view = "cmdline",
      },
    },
  },

  -- ── Statusline ────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function harpoon_component()
        local list = require("harpoon"):list()
        local total = list:length()
        if total == 0 then
          return ""
        end
        return string.format("󱡅 %d", total)
      end

      local filetype_map = {
        lazy = { name = "lazy.nvim", icon = "💤" },
        minifiles = { name = "minifiles", icon = "🗂️ " },
        snacks_terminal = { name = "terminal", icon = "🐚" },
        mason = { name = "mason", icon = "🔨" },
        TelescopePrompt = { name = "telescope", icon = "🔍" },
      }

      require("lualine").setup({
        options = {
          component_separators = { left = " ", right = " " },
          section_separators = { left = " ", right = " " },
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              icon = "",
              fmt = function(mode)
                return mode:lower()
              end,
            },
          },
          lualine_b = { { "branch", icon = "" }, harpoon_component },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = " ",
                warn = " ",
                info = " ",
                hint = "󰝶 ",
              },
            },
            {
              function()
                local devicons = require("nvim-web-devicons")
                local ft = vim.bo.filetype
                if filetype_map[ft] then
                  return " " .. filetype_map[ft].icon
                end
                local icon = devicons.get_icon(vim.fn.expand("%:t"))
                    or devicons.get_icon_by_filetype(ft)
                    or " 󰈤"
                return icon .. " "
              end,
              color = function()
                local _, hl = require("nvim-web-devicons").get_icon(vim.fn.expand("%:t"))
                if hl then
                  return hl
                end
                return utils.get_hlgroup("Normal")
              end,
              separator = "",
              padding = { left = 0, right = 0 },
            },
            {
              "filename",
              padding = { left = 0, right = 0 },
              fmt = function(name)
                if filetype_map[vim.bo.filetype] then
                  return filetype_map[vim.bo.filetype].name
                end
                return name
              end,
            },
            {
              function()
                return "+" .. utils.get_buffer_count() - 1 .. " "
              end,
              cond = function()
                return utils.get_buffer_count() > 1
              end,
              color = utils.get_hlgroup("Operator", nil),
              padding = { left = 0, right = 1 },
            },
            {
              function()
                local tab_count = vim.fn.tabpagenr("$")
                if tab_count > 1 then
                  return vim.fn.tabpagenr() .. " of " .. tab_count
                end
              end,
              cond = function()
                return vim.fn.tabpagenr("$") > 1
              end,
              icon = "󰓩",
              color = utils.get_hlgroup("Special", nil),
            },
          },
          lualine_x = {
            {
              ---@diagnostic disable: undefined-field
              require("noice").api.status.mode.get,
              cond = function()
                local ignore = {
                  "-- INSERT --",
                  "-- TERMINAL --",
                  "-- VISUAL --",
                  "-- VISUAL LINE --",
                  "-- VISUAL BLOCK --",
                }
                local mode = require("noice").api.status.mode.get()
                return require("noice").api.status.mode.has() and not vim.tbl_contains(ignore, mode)
              end,
              color = utils.get_hlgroup("Comment"),
              ---@diagnostic enable: undefined-field
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = utils.get_hlgroup("String"),
            },
            { "diff" },
          },
          lualine_y = {
            { "progress" },
            { "location", color = utils.get_hlgroup("Boolean") },
          },
          lualine_z = {
            { "datetime", style = "  %X" },
          },
        },
      })
    end,
  },

  -- ── Which-key ────────────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      win = {
        border = "single",
        padding = { 1, 2, 1, 2 },
        zindex = 1000,
        wo = { winblend = 0 },
      },
      layout = {
        height = { min = 4, max = 10 },
        width = { min = 10, max = 30 },
        spacing = 3,
        align = "left",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>a", group = " AI/Claude" },
        { "<leader>b", group = "󰓩 Buffers" },
        { "<leader>d", group = " Debug Print" },
        { "<leader>F", group = "󱃖 Flutter Tools" },
        { "<leader>f", group = " Find" },
        { "<leader>g", group = "󰊢 Git" },
        { "<leader>h", group = "󱂬 Harpoon" },
        { "<leader>l", group = " LSP" },
        { "<leader>n", group = "󰅌 Other" },
        { "<leader>s", group = "󰈭 Search/Replace" },
        { "<leader>t", group = " Terminal" },
        { "<leader>u", group = " UI" },
        { "<leader>x", group = "󰒡 Trouble" },
      })
    end,
  },

  -- ── LSP progress ───────────────────────────────────────────────────────────
  {
    "j-hui/fidget.nvim",
    event = "BufReadPost",
    opts = {
      notification = {
        window = { winblend = 0 },
      },
    },
  },

  -- ── vim.ui.select / input ────────────────────────────────────────────────
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ── Indent guides ─────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    opts = {
      indent = { char = "▏" },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    },
  },

  -- ── Snacks (zoom / zen) ────────────────────────────────────────────────────
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      styles = {
        zen = {
          position = "float",
          backdrop = 60,
          height = 0.9,
          width = 0.9,
          zindex = 50,
          border = true,
        },
      },
      zen = {
        win = { style = "zen" },
        zoom = {
          toggles = {},
          center = true,
          show = { statusline = true, tabline = true },
        },
      },
    },
    keys = {
      {
        "<leader>z",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle Zoom",
      },
      {
        "<leader>Z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
    },
  },
}
