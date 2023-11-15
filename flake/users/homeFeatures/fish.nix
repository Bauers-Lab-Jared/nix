{ lib, config, pkgs, osConfig, ... }: with lib; 
let
  hasNeovim = builtins.elem "nvim" osConfig.thisConfig.features;
in
{
  config = {
    programs.fish = {
      enable = mkDefault true;

      shellAbbrs = mkDefault rec {
      jqless = "jq -C | less -r";

      n = "nix";
      nd = "nix develop -c $SHELL";
      ns = "nix shell";
      nsn = "nix shell nixpkgs#";
      nb = "nix build";
      nbn = "nix build nixpkgs#";
      nf = "nix flake";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

      vim = mkIf hasNeovim "nvim";
      vi = vim;
      v = vim;
    };
    shellAliases = mkDefault {
      # Clear screen and scrollback
      clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
    };
    functions = mkDefault {
      # Disable greeting
      fish_greeting = "echo This is the fish shell with some general configuration.";
    };

    interactiveShellInit = mkDefault (
      # Open command buffer in vim when alt+e is pressed
      ''
        bind \ee edit_command_buffer
      '' +
      # Use vim bindings and cursors
      ''
        fish_vi_key_bindings
        set fish_cursor_default     block      blink
        set fish_cursor_insert      line       blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual      block
      '' +
      # colors from catppuccin
      ''
        set -U fish_color_normal cdd6f4
        set -U fish_color_command 89b4fa
        set -U fish_color_param f2cdcd
        set -U fish_color_keyword f38ba8
        set -U fish_color_quote a6e3a1
        set -U fish_color_redirection f5c2e7
        set -U fish_color_end fab387
        set -U fish_color_comment 7f849c
        set -U fish_color_error f38ba8
        set -U fish_color_gray 6c7086
        set -U fish_color_selection --background=313244
        set -U fish_color_search_match --background=313244
        set -U fish_color_option a6e3a1
        set -U fish_color_operator f5c2e7
        set -U fish_color_escape eba0ac
        set -U fish_color_autosuggestion 6c7086
        set -U fish_color_cancel f38ba8
        set -U fish_color_cwd f9e2af
        set -U fish_color_user 94e2d5
        set -U fish_color_host 89b4fa
        set -U fish_color_host_remote a6e3a1
        set -U fish_color_status f38ba8
        set -U fish_pager_color_progress 6c7086
        set -U fish_pager_color_prefix f5c2e7
        set -U fish_pager_color_completion cdd6f4
        set -U fish_pager_color_description 6c7086
    '');
    };
  };
}
