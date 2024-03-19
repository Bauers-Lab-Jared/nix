moduleArgs @ {
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  osConfig,
  ...
}:
with moduleArgs.lib.thisFlake; let
  scope = mkFeatureScope {
    moduleFilePath = __curPos.file;
    inherit moduleArgs;
  };
in
  with scope; let
    imports = with inputs; [
      nixvim.homeManagerModules.nixvim
    ];

    featOptions = with types; {
    };

    featConfig = mkMerge [
      (WITH_HOME_FEAT_PATH {
        features = enableFeatList [
          "ripgrep"
          "fd"
        ];
      })
      {
        home.packages = with pkgs; [
          alejandra
          codespell
          stylua
        ];

        programs.nixvim = {
          enable = true;
          viAlias = true;
          vimAlias = true;

          globals.mapleader = " ";

          extraConfigLua = ''
            vim.opt.undodir = os.getenv("HOME") .."/.persist/nvim/undodir";
          '';

          options = {
            timeoutlen = 0;

            number = true; # Show line numbers
            relativenumber = true; # Show relative line numbers

            tabstop = 4;
            softtabstop = 4;
            expandtab = true;
            shiftwidth = 4;

            smartindent = true;

            wrap = false;

            swapfile = false;
            backup = false;
            undofile = true;

            hlsearch = false;
            incsearch = true;

            termguicolors = true;

            scrolloff = 8;
            signcolumn = "yes";

            updatetime = 50;

            colorcolumn = "80";
          };

          extraPlugins = with pkgs.vimPlugins; [
            onedark-nvim
            dressing-nvim
            nvim-web-devicons
          ];

          colorscheme = "onedark";

          plugins.lualine.enable = true;

          plugins.undotree = {
            enable = true;

            settings = {
              CursorLine = true;
              DiffAutoOpen = true;
              DiffCommand = "diff";
              DiffpanelHeight = 10;
              HelpLine = true;
              HighlightChangedText = true;
              HighlightChangedWithSign = true;
              HighlightSyntaxAdd = "DiffAdd";
              HighlightSyntaxChange = "DiffChange";
              HighlightSyntaxDel = "DiffDelete";
              RelativeTimestamp = true;
              SetFocusWhenToggle = true;
              ShortIndicators = false;
              SplitWidth = 40;
              TreeNodeShape = "*";
              TreeReturnShape = "\\";
              TreeSplitShape = "/";
              TreeVertShape = "|";
              WindowLayout = 4;
            };
          };

          plugins.harpoon = {
            enable = true;
            enableTelescope = true;
            markBranch = true;
            tmuxAutocloseWindows = true;

            keymaps.addFile = "<leader>sa";
            keymaps.toggleQuickMenu = "<leader>sf";
            keymaps.cmdToggleQuickMenu = "<leader>sc";
            keymaps.navFile = {
              "1" = "g1";
              "2" = "g2";
              "3" = "g3";
              "4" = "g4";
            };
            keymaps.gotoTerminal = {
              "1" = "g6";
              "2" = "g7";
              "3" = "g8";
              "4" = "g9";
            };
          };

          plugins.cmp = {
            enable = true;
            autoEnableSources = true;

            settings = {
              sources = [
                {
                  name = "nvim_lsp";
                }
                {
                  name = "luasnip";
                }
                {
                  name = "path";
                }
                {
                  name = "buffer";
                }
              ];

              mapping = {
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                "<C-e>" = "cmp.mapping.close()";
                "<C-u>" = "cmp.mapping.scroll_docs(4)";
                "<C-y>" = "cmp.mapping.confirm({ select = true })";
                "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              };
            };
          };

          plugins.cmp-buffer.enable = true;
          plugins.cmp-nvim-lsp-document-symbol.enable = true;
          plugins.cmp-nvim-lsp-signature-help.enable = true;
          plugins.cmp-nvim-lsp.enable = true;
          plugins.cmp-path.enable = true;
          plugins.cmp_luasnip.enable = true;
          plugins.fugitive.enable = true;
          plugins.lsp-lines.enable = true;
          plugins.lspkind.enable = true;

          plugins.nvim-lightbulb = {
            enable = true;
            settings = {
              autocmd = {
                enabled = true;
                updatetime = 200;
              };
              float = {
                enabled = false;
                text = " 󰌶 ";
                win_opts = {
                  border = "rounded";
                };
              };
              line = {
                enabled = false;
              };
              number = {
                enabled = false;
              };
              sign = {
                enabled = true;
                text = "󰌶";
              };
              status_text = {
                enabled = false;
                text = " 󰌶 ";
              };
              virtual_text = {
                enabled = false;
                text = "󰌶";
              };
            };
          };

          plugins.mini = {
            enable = true;
            modules = {
              ai = {
                n_lines = 500;
              };
              surround = {};
              comment = {};
              operators = {};
              files = {};
              bracketed = {};
              hipatterns = {
                highlighters = {
                  # Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                  fixme = {
                    pattern = ''%f[%w]()FIXME()%f[%W]'';
                    group = "MiniHipatternsFixme";
                  };
                  hack = {
                    pattern = ''%f[%w]()HACK()%f[%W]'';
                    group = "MiniHipatternsHack";
                  };
                  todo = {
                    pattern = ''%f[%w]()TODO()%f[%W]'';
                    group = "MiniHipatternsTodo";
                  };
                  note = {
                    pattern = ''%f[%w]()NOTE()%f[%W]'';
                    group = "MiniHipatternsNote";
                  };

                  # Highlight hex color strings (`#rrggbb`) using that color
                  hex_color = "hipatterns.gen_highlighter.hex_color()";
                };
              };
            };
          };

          plugins.fidget = {
            enable = true;
            logger.path = {__raw = "string.format('%s/.persist/nvim/fidget.nvim.log', os.getenv('HOME'))";};
          };

          plugins.nix.enable = true;

          plugins.lsp = {
            enable = true;

            servers = {
              lua-ls = {
                enable = true;
                settings.telemetry.enable = false;
              };

              cssls.enable = true;

              # nixd = {
              #   enable = true;
              #   package = inputs.nixd.packages.${system}.nixd;
              # };
              nil_ls.enable = true;
            };

            keymaps = {
              diagnostic = {
                "<leader>cq" = "setloclist";
              };
              lspBuf = {
                "<leader>cr" = "rename";
                "<leader>ca" = "code_action";
                "<leader>cc" = "hover";
                "<leader>cR" = "references";
                "<leader>cd" = "definition";
                "<leader>ci" = "implementation";
                "<leader>cD" = "type_definition";
              };
            };
          };

          keymaps = [
            {
              key = ",";
              action = ":";
              options.desc = ":";
            }
            {
              key = "<leader>e";
              action = "<cmd>lua MiniFiles.open()<CR>";
              options.desc = "[E]xplore (file browser)";
              mode = "n";
            }
            {
              key = "<Esc>";
              action = "<C-\\><C-n>";
              mode = "t";
            }
            {
              key = "<leader>u";
              action = "vim.cmd.UndotreeToggle";
              options.desc = "[U]ndotree";
              lua = true;
              mode = "n";
            }
            {
              key = "<leader>gg";
              action = "<cmd>Git<CR>";
              options.desc = "[g]it status";
              mode = "n";
            }
            {
              key = "<leader>gb";
              action = "<cmd>Git blame<CR>";
              options.desc = "Git [b]lame";
              mode = "n";
            }
            {
              key = "<leader>gd";
              action = "<cmd>Git diff<CR>";
              options.desc = "Git [d]iff";
              mode = "n";
            }
            {
              key = "<leader>gl";
              action = "<cmd>Git log<CR>";
              options.desc = "Git [l]og";
              mode = "n";
            }
            {
              key = "<leader>gm";
              action = "<cmd>Git mergetool<CR>";
              options.desc = "Git [m]ergetool";
              mode = "n";
            }
            {
              key = "<leader>gD";
              action = "<cmd>Git difftool<CR>";
              options.desc = "Git [d]ifftool";
              mode = "n";
            }
          ];

          plugins.telescope = {
            enable = true;
            highlightTheme = "onedark";
            keymaps = {
              "<leader>fG" = {
                action = "git_files";
                desc = "[f]ind [G]it files";
              };
              "<leader>fh" = {
                action = "help_tags";
                desc = "[f]ind [h]elp";
              };
              "<leader>fk" = {
                action = "keymaps";
                desc = "[f]ind [k]eymaps";
              };
              "<leader>ff" = {
                action = "find_files";
                desc = "[f]ind [f]iles";
              };
              "<leader>fs" = {
                action = "builtin";
                desc = "[f]ind [s]elect Telescope";
              };
              "<leader>fw" = {
                action = "grep_string";
                desc = "[f]ind Current [w]ord";
              };
              "<leader>fg" = {
                action = "live_grep";
                desc = "[f]ind by [g]rep";
              };
              "<leader>fd" = {
                action = "diagnostics";
                desc = "[f]ind [d]iagnostics";
              };
              "<leader>fr" = {
                action = "resume";
                desc = "[f]ind [r]esume";
              };
              "<leader>f." = {
                action = "oldfiles";
                desc = "[f]ind Recent Files ('.' for repeat)";
              };
              "<leader><leader>" = {
                action = "buffers";
                desc = "[ ]Find Existing Buffers";
              };
            };
          };

          plugins.treesitter = {
            enable = true;
            nixvimInjections = true;
            indent = true;
            incrementalSelection.enable = true;
          };

          plugins.luasnip.enable = true;

          plugins.which-key = {
            enable = true;
            registrations = {
              "<leader>f" = "[f]ind ...";
              "<leader>g" = "[g]it ...";
              "<leader>c" = "[c]ode ...";
              "<leader>cq" = "[q]uickfix diagnostic";
              "<leader>cR" = "[R]ename";
              "<leader>ca" = "Code [A]ction";
              "<leader>cd" = "[d]efinition";
              "<leader>cD" = "Type [D]efinition";
              "<leader>cr" = "Definition [r]eferences";
              "<leader>ci" = "[i]mplementation";
              "<leader>cc" = "[c]ode Documentation";
              "<leader>s" = "[s]hort cuts ...";
              "<leader>sa" = "[a]dd This File";
              "<leader>sf" = "[f]iles Menu";
              "<leader>sc" = "[c]mds Menu";
              "g1" = "goto 1st Shortcut File";
              "g2" = "goto 2nd Shortcut File";
              "g3" = "goto 3rd Shortcut File";
              "g4" = "goto 4th Shortcut File";
              "g6" = "goto 1st Shortcut Terminal";
              "g7" = "goto 2nd Shortcut Terminal";
              "g8" = "goto 3rd Shortcut Terminal";
              "g9" = "goto 4th Shortcut Terminal";
            };
          };

          plugins.conform-nvim = {
            enable = true;

            formatOnSave = {
              lspFallback = true;
              timeoutMs = 500;
            };

            formattersByFt = {
              nix = ["alejandra"];
              lua = ["stylua"];
              # use the "*" filetype to run formatters on all filetypes.
              "*" = ["codespell"];
            };
          };

          plugins.indent-blankline = {
            enable = true;
            scope.showExactScope = true;
          };

          plugins.rainbow-delimiters = {
            enable = true;
            whitelist = ["nix"];
          };

          extraConfigLuaPre = ''
            require('onedark').setup {
                style = 'deep'
            }
            require('onedark').load()
          '';

          extraConfigLuaPost = ''
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }
            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
            end)

            vim.g.rainbow_delimiters = { highlight = highlight }
            require("ibl").setup { scope = { highlight = highlight } }

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
          '';
        };
        home.sessionVariables = {EDITOR = "nvim";};
        programs.bash.shellAliases = {"v" = "vi";};
      }
    ];
  in
    mkFeatureFile {inherit scope featOptions featConfig imports;}
