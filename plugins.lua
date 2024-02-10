local plugins = {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "gopls"
      }
    }
  },
  {
    "mfussenegger/nvim-dap",
    init = function()
      require("core.utils").load_mappings("dap")
    end
  },
  {
    "dreamsofcode-io/nvim-dap-go",
    ft           = "go",
    dependencies = "mfussenegger/nvim-dap",
    config       = function(_, opts)
      require("dap-go").setup(opts)
      require("core.utils").load_mappings("dap_go")
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end
  },
  {
    "olexsmir/gopher.nvim",
    ft     = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
      require("core.utils").load_mappings("gopher")
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts  = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true
        }
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any   = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" }
            }
          },
          view = "mini"
        }
      },
      presets = {
        bottom_search         = true,
        command_palette       = true,
        long_message_to_split = true,
        inc_rename            = true
      }
    },
    -- stylua: ignore
    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline"
      },
      {
        "<leader>snl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice Last Message"
      },
      {
        "<leader>snh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice History"
      },
      {
        "<leader>sna",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice All"
      },
      {
        "<leader>snd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All"
      },
      {
        "<c-f>",
        function()
       if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr   = true,
        desc   = "Scroll forward",
        mode   = { "i", "n", "s" }
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr   = true,
        desc   = "Scroll backward",
        mode   = { "i", "n", "s" }
      }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL: 
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify"
    }
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
  {
    "stevearc/conform.nvim",
          opts           = function()
    local plugin         = require("lazy.core.config").plugins["conform.nvim"]
    if    plugin.config ~= M.setup then
        Util.error(
          {
            "Don't set `plugin.config` for `conform.nvim`.\n",
            "This will break **LazyVim** formatting.\n",
            "Please refer to the docs at https://www.lazyvim.org/plugins/formatting"
          },
          { title = "LazyVim" }
        )
      end
      ---@class ConformOpts
      local opts = {
        -- LazyVim will use these options when formatting with the conform.nvim formatter
        format = {
          timeout_ms = 3000,
          async      = false, -- not recommended to change
          quiet      = false          -- not recommended to change
        },
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = {
          lua  = { "stylua" },
          fish = { "fish_indent" },
          sh   = { "shfmt" },
          go   = { "goimports", "gofmt", "golines", "goimports-reviser", "gofumpt" }
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } }
          -- # Example of using dprint only when a dprint.json file is present
          -- dprint = {
          -- condition = function(ctx)
          --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
          --
          -- # Example of using shfmt with extra args
          -- shfmt = {
          -- prepend_args = { "-i", "2", "-ci" },
          -- },
        }
      }
      return opts
    end
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts  = { options = vim.opt.sessionoptions:get() },
    -- stylua: ignore
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session"
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session"
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session"
      }
    }
  },
  {
    "nvimdev/dashboard-nvim",
    event  = "VimEnter",
    config = function()
      require("dashboard").setup {
        -- config
        theme  = "hyper",
        config = {
          week_header = {
            enable = true
          },
          shortcut = {
            { desc = "󰚰 Update", group = "@property", action = "Lazy update", key = "u" },
            {
              icon_hl = "@variable",
              desc    = " Files",
              group   = "Label",
              action  = "Telescope find_files",
              key     = "f"
            },
            {
              desc   = " Apps",
              group  = "DiagnosticHint",
              action = "Telescope app",
              key    = "a"
            },
            {
              desc   = " dotfiles",
              group  = "Number",
              action = "Telescope dotfiles",
              key    = "d"
            }
          },
          project = {
            enable = false
          }
        }
      }
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } }
  },
  {
    "mhartington/formatter.nvim"
  },
  {
    "folke/todo-comments.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts         = {}
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>tx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>tX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>tL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>tQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous trouble/quickfix item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    dependencies = { "mason.nvim" },
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.code_actions.gomodifytags,
        nls.builtins.code_actions.impl,
        nls.builtins.formatting.goimports,
        nls.builtins.formatting.gofumpt,
      })
    end,
  },
  { 
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    }
  },
  {
    "LintaoAmons/cd-project.nvim",
    event= "VeryLazy",
    -- Don't need call the setup function if you think you are good with the default configuration
    config = function()
      require("cd-project").setup({
        -- this json file is acting like a database to update and read the projects in real time.
        -- So because it's just a json file, you can edit directly to add more paths you want manually
        projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
        -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
        choice_format = "both", -- optional, you can switch to "name" or "path"
        projects_picker = "vim-ui", -- optional, you can switch to `telescope`
        -- do whatever you like by hooks
        hooks = {
          {
            callback = function(dir)
              vim.notify("switched to dir: " .. dir)
            end,
          },
          {
            callback = function(dir)
              vim.notify("switched to dir: " .. dir)
            end, -- required, action when trigger the hook
            name = "cd hint", -- optional
            order = 1, -- optional, the exection order if there're multiple hooks to be trigger at one point
            pattern = "cd-project.nvim", -- optional, trigger hook if contains pattern
            trigger_point = "DISABLE", -- optional, enum of trigger_points, default to `AFTER_CD`
            match_rule = function(dir) -- optional, a function return bool. if have this fields, then pattern will be ignored
              return true
            end,
          },
        },
      })
    end,
  }
}
return plugins
