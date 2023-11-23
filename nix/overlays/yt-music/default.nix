{ channels, ... }:

final: prev: {
  thisFlake = (prev.thisFlake or { }) // {
    yt-music = prev.makeDesktopItem {
      name = "YT Music";
      desktopName = "YT Music";
      genericName = "Music, from YouTube.";
      exec = ''
        ${final.mullvad-browser}/bin/mullvad-browser "https://music.youtube.com/?thisFlake.app=true"'';
      icon = ./icon.svg;
      type = "Application";
      categories = [ "AudioVideo" "Audio" "Player" ];
      terminal = false;
    };
  };
}
