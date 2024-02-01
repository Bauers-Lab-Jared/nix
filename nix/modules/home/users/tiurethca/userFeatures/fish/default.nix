{
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
}: with lib;
with lib.thisFlake;
let
  featureName = baseNameOf (toString ./.);
  username = baseNameOf (toString ../../.);
  cfg = config.thisFlake.userFeatures.${username}.${featureName};
in 
{

  options = mkUserFeature {inherit config osConfig username featureName; otherOptions = {
      userFeatures.${username}.${featureName} = {
        
      };
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      
    functions = {
      # Disable greeting
      fish_greeting = "echo Tiurethca Fish";
    };

    interactiveShellInit = (
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