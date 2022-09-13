{
  description = "Vim pugin for email management.";

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
        in
        rec {
          # nix build
          defaultPackage = pkgs.vimUtils.buildVimPluginFrom2Nix {
            src = self;
            name = "himalaya";
            version = pkgs.himalaya.version;
            buildInputs = [ pkgs.himalaya ];
            dontConfigure = false;
            postInstall = ''
              mkdir -p $out/bin
              ln -s ${pkgs.himalaya}/bin/himalaya $out/bin/himalaya
            '';
          };

          # nix develop
          devShell = pkgs.mkShell {
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
              vim
              neovim
            ];
          };
        }
      );
}
