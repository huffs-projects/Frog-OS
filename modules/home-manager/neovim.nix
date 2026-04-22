{ config, pkgs, theme, ... }:

let
  # Helper function to convert hex color to RGB values for Lua
  hexToRgb = hex:
    let
      hexClean = builtins.replaceStrings ["#"] [""] hex;
      rHex = builtins.substring 0 2 hexClean;
      gHex = builtins.substring 2 2 hexClean;
      bHex = builtins.substring 4 2 hexClean;
      hexCharToDec = c:
        if c == "0" then 0
        else if c == "1" then 1
        else if c == "2" then 2
        else if c == "3" then 3
        else if c == "4" then 4
        else if c == "5" then 5
        else if c == "6" then 6
        else if c == "7" then 7
        else if c == "8" then 8
        else if c == "9" then 9
        else if c == "a" || c == "A" then 10
        else if c == "b" || c == "B" then 11
        else if c == "c" || c == "C" then 12
        else if c == "d" || c == "D" then 13
        else if c == "e" || c == "E" then 14
        else if c == "f" || c == "F" then 15
        else 0;
      hexToDec = s:
        let
          first = builtins.substring 0 1 s;
          second = builtins.substring 1 1 s;
        in (hexCharToDec first) * 16 + (hexCharToDec second);
    in {
      r = hexToDec rHex;
      g = hexToDec gHex;
      b = hexToDec bHex;
    };
  
  # Convert theme colors to RGB
  bgRgb = hexToRgb theme.bg;
  fgRgb = hexToRgb theme.fg;
  accentRgb = hexToRgb theme.accent;
  redRgb = hexToRgb theme.red;
  greenRgb = hexToRgb theme.green;
  yellowRgb = hexToRgb theme.yellow;
  blueRgb = hexToRgb theme.blue;
  magentaRgb = hexToRgb theme.magenta;
  cyanRgb = hexToRgb theme.cyan;
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    package = null;  # Use system package
    
    # Install lazy.nvim via Nix (bootstrap)
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
    
    # Bootstrap lazy.nvim and load configuration
    extraLuaConfig = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)
      
      -- Load configuration files
      require("config.options")
      require("config.keymaps")
      require("config.lazy")
    '';
  };
  
  # Neovim configuration files
  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Neovim options
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.cursorline = true
    vim.opt.wrap = false
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.termguicolors = true
    vim.opt.signcolumn = "yes"
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 250
    vim.opt.timeoutlen = 300
  '';
  
  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- Keybindings
    local map = vim.keymap.set
    
    -- Leader key
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    
    -- Better escape
    map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
    
    -- Navigation
    map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
    map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
    
    -- Window navigation
    map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
    map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
    map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
    map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
    
    -- Buffer navigation
    map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
    map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
    map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
    
    -- Clear search highlights
    map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
    
    -- Save file
    map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
    
    -- Quit
    map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
  '';
  
  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    -- lazy.nvim configuration
    require("lazy").setup({
      -- LSP
      {
        "neovim/nvim-lspconfig",
        dependencies = {
          "williamboman/mason.nvim",
          "williamboman/mason-lspconfig.nvim",
        },
        config = function()
          require("plugins.lsp")
        end,
      },
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
      },
      {
        "williamboman/mason-lspconfig.nvim",
      },
      
      -- Treesitter
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          require("plugins.treesitter")
        end,
      },
      
      -- Autocompletion
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_lua_snip",
        },
        config = function()
          require("plugins.cmp")
        end,
      },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_lua_snip" },
      
      -- Telescope
      {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          require("plugins.telescope")
        end,
      },
      { "nvim-lua/plenary.nvim" },
      
      -- File explorer
      {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
          require("plugins.nvim-tree")
        end,
      },
      { "nvim-tree/nvim-web-devicons" },
      
      -- Which-key
      {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 300
        end,
        config = function()
          require("which-key").setup()
        end,
      },
      
      -- Colorschemes (theme-aware)
      { "ellisonleao/gruvbox.nvim" },
      { "rebelot/kanagawa.nvim" },
      { "nordtheme/vim" },
      { "EdenEast/nightfox.nvim" },
    }, {
      install = {
        colorscheme = { "frogos" },
      },
      checker = {
        enabled = true,
        notify = false,
      },
      change_detection = {
        notify = false,
      },
    })
  '';
  
  xdg.configFile."nvim/lua/plugins/lsp.lua".text = ''
    -- LSP configuration
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    -- Setup language servers
    local servers = { "lua_ls", "nil_ls", "bashls" }
    
    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end
    
    -- Keybindings for LSP
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "Format" })
    
    -- Diagnostic keybindings
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
  '';
  
  xdg.configFile."nvim/lua/plugins/treesitter.lua".text = ''
    -- Treesitter configuration
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "nix", "bash", "python", "rust", "javascript", "typescript", "json", "yaml", "markdown" },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  '';
  
  xdg.configFile."nvim/lua/plugins/cmp.lua".text = ''
    -- Autocompletion configuration
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })
  '';
  
  xdg.configFile."nvim/lua/plugins/telescope.lua".text = ''
    -- Telescope configuration
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
    })
    
    -- Keybindings
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
  '';
  
  xdg.configFile."nvim/lua/plugins/nvim-tree.lua".text = ''
    -- Nvim-tree configuration
    require("nvim-tree").setup({
      view = {
        width = 30,
      },
      renderer = {
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "▶",
              arrow_open = "▼",
            },
          },
        },
      },
    })
    
    -- Keybinding
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
  '';
  
  # Custom FrogOS colorscheme using theme colors
  xdg.configFile."nvim/colors/frogos.lua".text = ''
    -- FrogOS colorscheme
    -- Generated from theme colors
    
    local colors = {
      bg = "#${builtins.replaceStrings ["#"] [""] theme.bg}",
      fg = "#${builtins.replaceStrings ["#"] [""] theme.fg}",
      accent = "#${builtins.replaceStrings ["#"] [""] theme.accent}",
      red = "#${builtins.replaceStrings ["#"] [""] theme.red}",
      green = "#${builtins.replaceStrings ["#"] [""] theme.green}",
      yellow = "#${builtins.replaceStrings ["#"] [""] theme.yellow}",
      blue = "#${builtins.replaceStrings ["#"] [""] theme.blue}",
      magenta = "#${builtins.replaceStrings ["#"] [""] theme.magenta}",
      cyan = "#${builtins.replaceStrings ["#"] [""] theme.cyan}",
    }
    
    -- Helper function to lighten/darken colors
    local function lighten(hex, amount)
      -- Simple lightening by adding to RGB values
      local r = tonumber(string.sub(hex, 2, 3), 16)
      local g = tonumber(string.sub(hex, 4, 5), 16)
      local b = tonumber(string.sub(hex, 6, 7), 16)
      r = math.min(255, r + amount)
      g = math.min(255, g + amount)
      b = math.min(255, b + amount)
      return string.format("#%02x%02x%02x", r, g, b)
    end
    
    local function darken(hex, amount)
      local r = tonumber(string.sub(hex, 2, 3), 16)
      local g = tonumber(string.sub(hex, 4, 5), 16)
      local b = tonumber(string.sub(hex, 6, 7), 16)
      r = math.max(0, r - amount)
      g = math.max(0, g - amount)
      b = math.max(0, b - amount)
      return string.format("#%02x%02x%02x", r, g, b)
    end
    
    local bg_light = lighten(colors.bg, 15)
    local fg_dim = darken(colors.fg, 60)
    
    -- Set colorscheme
    vim.g.colors_name = "frogos"
    
    -- Clear existing highlights
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
      vim.cmd("syntax reset")
    end
    
    -- Base colors
    vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
    vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg, bg = colors.bg })
    vim.api.nvim_set_hl(0, "NormalNC", { fg = colors.fg, bg = colors.bg })
    
    -- Cursor and selection
    vim.api.nvim_set_hl(0, "Cursor", { fg = colors.bg, bg = colors.fg })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = bg_light })
    vim.api.nvim_set_hl(0, "CursorColumn", { bg = bg_light })
    vim.api.nvim_set_hl(0, "Visual", { bg = colors.accent, fg = colors.bg })
    vim.api.nvim_set_hl(0, "VisualNOS", { bg = colors.accent, fg = colors.bg })
    
    -- Line numbers
    vim.api.nvim_set_hl(0, "LineNr", { fg = fg_dim })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.accent, bold = true })
    
    -- Status line
    vim.api.nvim_set_hl(0, "StatusLine", { fg = colors.bg, bg = colors.accent })
    vim.api.nvim_set_hl(0, "StatusLineNC", { fg = colors.fg, bg = bg_light })
    
    -- Syntax highlighting
    vim.api.nvim_set_hl(0, "Comment", { fg = fg_dim, italic = true })
    vim.api.nvim_set_hl(0, "String", { fg = colors.green })
    vim.api.nvim_set_hl(0, "Keyword", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "Function", { fg = colors.cyan })
    vim.api.nvim_set_hl(0, "Type", { fg = colors.yellow })
    vim.api.nvim_set_hl(0, "Constant", { fg = colors.magenta })
    vim.api.nvim_set_hl(0, "Identifier", { fg = colors.fg })
    vim.api.nvim_set_hl(0, "Statement", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "PreProc", { fg = colors.magenta })
    vim.api.nvim_set_hl(0, "Special", { fg = colors.cyan })
    vim.api.nvim_set_hl(0, "Number", { fg = colors.magenta })
    vim.api.nvim_set_hl(0, "Boolean", { fg = colors.blue })
    
    -- Diagnostics
    vim.api.nvim_set_hl(0, "Error", { fg = colors.red })
    vim.api.nvim_set_hl(0, "ErrorMsg", { fg = colors.red })
    vim.api.nvim_set_hl(0, "WarningMsg", { fg = colors.yellow })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.red })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.yellow })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.cyan })
    
    -- LSP
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = bg_light })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = bg_light })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = bg_light })
    
    -- Diff
    vim.api.nvim_set_hl(0, "DiffAdd", { fg = colors.green })
    vim.api.nvim_set_hl(0, "DiffDelete", { fg = colors.red })
    vim.api.nvim_set_hl(0, "DiffChange", { fg = colors.yellow })
    vim.api.nvim_set_hl(0, "DiffText", { fg = colors.blue })
    
    -- Search
    vim.api.nvim_set_hl(0, "Search", { fg = colors.bg, bg = colors.yellow })
    vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg, bg = colors.accent })
    
    -- Pmenu (completion menu)
    vim.api.nvim_set_hl(0, "Pmenu", { fg = colors.fg, bg = bg_light })
    vim.api.nvim_set_hl(0, "PmenuSel", { fg = colors.bg, bg = colors.accent })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = bg_light })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.fg })
    
    -- Sign column
    vim.api.nvim_set_hl(0, "SignColumn", { bg = colors.bg })
    
    -- Fold
    vim.api.nvim_set_hl(0, "Folded", { fg = fg_dim, bg = bg_light })
    vim.api.nvim_set_hl(0, "FoldColumn", { fg = fg_dim })
  '';
  
  # Set default colorscheme in init
  xdg.configFile."nvim/init.lua".text = ''
    -- Load custom colorscheme
    vim.cmd("colorscheme frogos")
  '';
}
