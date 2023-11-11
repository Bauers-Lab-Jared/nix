{ config, pkgs, lib, ... }: {
  
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    options = {
        nu = true;
        relativenumber = true;
        tabstop = 4;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        smartindent = true;
        wrap = false;
        swapfile = false;
        backup = false;
        undodir = "os.getenv(\"HOME\") .. \"/.nvim/undodir\"";
        undofile = true;
        hlsearch = false;
        incsearch = true;
        termguicolors = true;
        scrolloff = 8;
        signcolumn = "yes";
        updatetime = 50;
        colorcolumn = "120";
    };
  };
}