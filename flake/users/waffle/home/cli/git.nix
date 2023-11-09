{ pkgs, lib, config, osConfig, ... }:
{
  programs.git = lib.mkIf osConfig.programs.git.enable {
    userName = "Jared";
    userEmail = "127258074+Bauers-Lab-Jared@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      user.signing.key = "";
      commit.gpgSign = false;
    };
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
      fast-forward = "merge --ff-only";
    };
    lfs.enable = true;
    ignores = [ ".direnv" "result" ];
  };
}
