{
  description = "Vim plugin for email management.";

  inputs = {
    himalaya-dev.url = "github:soywod/himalaya/develop";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, himalaya-dev, utils, ... }:
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; };
          himalaya = (import himalaya-dev).defaultPackage.${system}; # Develop build
          # himalaya = pkgs.himalaya; # Master build (last release)
          name = "himalaya";
        in
        rec {
          # nix build
          defaultPackage = pkgs.vimUtils.buildVimPluginFrom2Nix {
            inherit name;
            namePrefix = "";
            src = self;
            version = himalaya.version;
            buildInputs = [ himalaya ];
          };

          # nix develop
          devShell = pkgs.mkShell {
            buildInputs = defaultPackage.buildInputs;
            nativeBuildInputs = with pkgs; [
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
