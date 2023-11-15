{ lib, config, ... }: with lib;
{
  config = {
    programs.git = {
      userName = "Jared";
      userEmail = "127258074+Bauers-Lab-Jared@users.noreply.github.com";
    };
  };
}
