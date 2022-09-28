{
  description = "Vim plugin for email management.";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          name = "himalaya";
        in
        rec {
          # nix build
          defaultPackage = pkgs.vimUtils.buildVimPluginFrom2Nix {
            inherit name;
            namePrefix = "";
            src = self;
            version = pkgs.himalaya.version;
            buildInputs = [ pkgs.himalaya ];
          };

          # nix develop
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; defaultPackage.buildInputs ++ [
              # Nix LSP + formatter
              rnix-lsp
              nixpkgs-fmt

              # Vim LSP
              nodejs
              nodePackages.vim-language-server

              # Lua LSP
              lua52Packages.lua-lsp

              # Editors
              ((vim_configurable.override { }).customize {
                name = "vim";
                vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
                  start = [ ];
                  opt = [ defaultPackage ];
                };
                vimrcConfig.customRC = ''
                  packadd! ${name}
                '';
              })
              (neovim.override {
                configure = {
                  packages.myPlugins = with pkgs.vimPlugins; {
                    start = [ telescope-nvim ];
                    opt = [ defaultPackage ];
                  };
                  customRC = ''
                    packadd! ${name}
                  '';
                };
              })
            ];
          };
        }
      );
}
