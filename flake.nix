{
  description = "Vim plugin for email management.";

  inputs = {
    himalaya-git.url = "github:soywod/himalaya/develop";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, himalaya-git, utils, ... }:
    utils.lib.eachDefaultSystem
      (system:
        let
          himalaya = himalaya-git.defaultPackage.${system};
          pkgs = import nixpkgs { inherit system; };
          customRC = ''
            syntax on
            filetype plugin on

            packadd! himalaya

            " native, fzf or telescope
            let g:himalaya_folder_picker = 'native'
            let g:himalaya_folder_picker_telescope_preview = v:false
            let g:himalaya_complete_contact_cmd = 'echo test@localhost'
          '';
        in
        rec {
          # nix build
          defaultPackage = pkgs.vimUtils.buildVimPluginFrom2Nix {
            name = "himalaya";
            namePrefix = "";
            src = self;
            buildInputs = [ himalaya ];
            postPatch = ''
              substituteInPlace plugin/himalaya.vim \
                --replace "default_executable = 'himalaya'" "default_executable = '${himalaya}/bin/himalaya'"
            '';
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

              # FZF
              fzf

              # Editors
              ((vim_configurable.override { }).customize {
                name = "vim";
                vimrcConfig = {
                  inherit customRC;
                  packages.myplugins = with pkgs.vimPlugins; {
                    start = [ fzf-vim ];
                    opt = [ defaultPackage ];
                  };
                };
              })
              (neovim.override {
                configure = {
                  inherit customRC;
                  packages.myPlugins = with pkgs.vimPlugins; {
                    start = [ telescope-nvim fzf-vim ];
                    opt = [ defaultPackage ];
                  };
                };
              })
            ];
          };
        }
      );
}
