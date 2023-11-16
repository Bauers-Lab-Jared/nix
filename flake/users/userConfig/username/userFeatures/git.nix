{ lib, config, ... }: with lib;
{
  config = {
    programs.git = {
      userName = "username";
      userEmail = "username@nowhere.not";
    };
  };
}
