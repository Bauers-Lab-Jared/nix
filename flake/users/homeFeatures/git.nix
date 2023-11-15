{featureName}: { lib, config, pkgs, ... }: with lib; 
let
  cfg = config.homeFeatures.${featureName};
in
{
  options.homeFeatures.${featureName}.enable =
    mkEnableOption "some standard config for git";

  config = mkIf cfg.enable {
    programs.git = {
      enable = mkDefault true;
      package = mkDefault pkgs.gitAndTools.gitFull;

      extraConfig = {
        init.defaultBranch = mkDefault "main";
        user.signing.key = mkDefault "";
        commit.gpgSign = mkDefault false;
      };
      aliases = mkDefault {
        pushall = "!git remote | xargs -L1 git push --all";
        graph = "log --decorate --oneline --graph";
        add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
        fast-forward = "merge --ff-only";
      };
      lfs.enable = mkDefault true;
      ignores = mkDefault [ ".direnv" "result" ];
    };
  };
}