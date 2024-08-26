{
  description = "Flake for building QMK firmware";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      keyboard = "boardsource/lulu/rp2040";
      keymap = "tony";
    in {
      # build with `nix build .?submodules=1`
      packages.default = pkgs.stdenv.mkDerivation {
        name = "keymap";
        src = ./.;
        phases = [ "buildPhase" ];
        buildInputs = [ pkgs.qmk ];
        buildPhase = ''
          make -C $src BUILD_DIR="$(pwd)"/.build COPY=echo -j8 ${keyboard}:${keymap}
          mkdir $out
          cp -r .build/* $out/
        '';
      };
      devShell = pkgs.mkShell {
        KEYBOARD = keyboard;
        KEYMAP = keymap;
        buildInputs = [ pkgs.qmk ];
        shellHook = ''
          factory_reset() {
            BUILD_DIR=''${1:-.build}
            make -C . BUILD_DIR=$BUILD_DIR COPY=echo -j8 $KEYBOARD:default
            make -C . BUILD_DIR=$BUILD_DIR COPY=echo -j8 $KEYBOARD:default:flash
          }
          build() {
            BUILD_DIR=''${1:-.build}
            make -C . BUILD_DIR=$BUILD_DIR COPY=echo -j8 $KEYBOARD:$KEYMAP
          }
          flash() {
            BUILD_DIR=''${1:-.build}
            make -C . BUILD_DIR=$BUILD_DIR COPY=echo -j8 $KEYBOARD:$KEYMAP:flash
          }
        '';
      };
    }
  );
}
