-- =====================================================================
-- ==================== KICKSTART.NVIM - OPTIMIZED =====================
-- =====================================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Editor Options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.cursorline = true   -- highlight current line
vim.opt.wrap = false        -- no line wrapping
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.keywordprg = ':help'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- FIX: vim.loop is deprecated in Neovim 0.10+; use vim.uv
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins with lazy.nvim ]]
require('lazy').setup({
  -- Official Dracula theme (Lua-native, supports lualine/gitsigns/telescope/nvim-tree)
  {
    'Mofiqul/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('dracula').setup {
        show_end_of_buffer = true,
        transparent_bg = false,
        italic_comment = true,
      }
      vim.cmd.colorscheme 'dracula'
    end,
  },

  { 'tpope/vim-fugitive', cmd = 'Git' },
  { 'tpope/vim-rhubarb', dependencies = { 'tpope/vim-fugitive' } },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '│' },
        change = { text = '│' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '│' },
      },
    },
  },

  'tpope/vim-sleuth',

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        -- FIX: use a theme compatible with darcula (auto falls back gracefully)
        theme = 'dracula-nvim',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = { animation = false },
    version = '^1.0.0',
    event = 'BufReadPre',
  },

  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },

  -- FIX: removed deprecated `tag = 'legacy'`; modern fidget.nvim API is stable
  { 'j-hui/fidget.nvim', opts = {}, event = 'LspAttach' },

  {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sort_by = "case_sensitive",
      view = { adaptive_size = true },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      update_focused_file = { enable = true },
    },
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },
  { 'windwp/nvim-ts-autotag', ft = { "html", "javascriptreact", "typescriptreact", "xml" } },
  { 'numToStr/Comment.nvim', opts = {}, keys = { 'gc', 'gcc', 'gbc' } },
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {}, event = 'BufReadPre' },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    dependencies = {
      { 'williamboman/mason.nvim', build = ':MasonUpdate' },
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim',
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'rafamadriz/friendly-snippets',
    },
  },

  {
    "scalameta/nvim-metals",
    ft = { "scala", "sbt" },
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    -- FIX: added proper metals configuration (was completely unconfigured before)
    config = function()
      local metals_config = require("metals").bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      }
      metals_config.on_attach = function(client, bufnr)
        -- reuse the shared on_attach defined later
        -- metals registers its own capabilities; we just call the keymap setup
        on_attach(client, bufnr)
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt", "java" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
      })
    end,
  },

  {
    -- Pinned to master branch: frozen but stable, ships pre-compiled parser
    -- binaries (no local compilation needed, avoids Windows build issues).
    -- Restores the full nvim-treesitter.configs API.
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    event = 'BufReadPre',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx',
        'javascript', 'typescript', 'vimdoc', 'vim', 'bash',
        'yaml', 'json', 'css', 'html', 'scala', 'graphql',
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    },
  },
}, {})

-- [[ Basic Keymaps ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, noremap = true, desc = "Toggle file explorer" })

-- [[ Barbar buffer keymaps ]]
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)
map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
map('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)

-- [[ Yank highlight ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Telescope ]]
require('telescope').setup {
  defaults = {
    mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } },
    file_ignore_patterns = { '^.git/', '^node_modules/' },
  },
}
pcall(require('telescope').load_extension, 'fzf')

local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = current_file and vim.fn.fnamemodify(current_file, ':h') or vim.fn.getcwd()
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  return (vim.v.shell_error == 0) and git_root or vim.fn.getcwd()
end

-- FIX: all telescope keymaps now use lazy wrappers to avoid eager loading
--      (calling require('telescope.builtin') at top level defeats lazy = true on cmd)
vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').oldfiles() end, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', function() require('telescope.builtin').buffers() end, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').live_grep() end, { desc = '[F]ind by [G]rep' })
vim.keymap.set('n', '<leader>fG', function()
  require('telescope.builtin').live_grep({ search_dirs = { find_git_root() } })
end, { desc = '[F]ind by [G]rep in Git Root' })
vim.keymap.set('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, { desc = '[F]ind [H]elp' })
vim.keymap.set('n', '<leader>fw', function() require('telescope.builtin').grep_string() end, { desc = '[F]ind current [W]ord' })
vim.keymap.set('n', '<leader>fd', function() require('telescope.builtin').diagnostics() end, { desc = '[F]ind [D]iagnostics' })
vim.keymap.set('n', '<leader>fr', function() require('telescope.builtin').resume() end, { desc = '[F]ind [R]esume' })

-- [[ LSP on_attach ]]
-- NOTE: defined before metals config block references it above
on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', function() require('telescope.builtin').lsp_definitions() end, '[G]oto [D]efinition')
  nmap('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
  nmap('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
  nmap('<leader>td', function() require('telescope.builtin').lsp_type_definitions() end, 'Type [D]efinition')
  nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
  nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format { async = true }
  end, { desc = 'Format current buffer with LSP' })
end

-- [[ Diagnostics keymaps ]]
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.open_float, { desc = 'Show diagnostic line' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Show diagnostics list' })

-- [[ Mason + LSP servers ]]
require('mason').setup()
require('neodev').setup()

local servers = {
  gopls = {},
  graphql = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  ts_ls = {},
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
      }
    end,
    ['gopls'] = function()
      require('lspconfig').gopls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            experimentalPostfixCompletions = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
          },
        },
      }
    end,
  },
}

-- [[ nvim-cmp ]]
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
