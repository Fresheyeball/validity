let
  pkgs = import ./nix/pkgs.nix {};
  versions = [
    "lts-15_03"
    "lts-15_15"
    "lts-16_11"
    "lts-16_20"
  ];
  copyPackage = pkgName: pkgPath: ''
    cp -r ${pkgPath} $out/${pkgName}
  '';
  mkTarget = name: ps:
      pkgs.stdenv.mkDerivation {
        name = name;
        buildCommand = ''
          mkdir $out

        '' + pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList copyPackage ps);
      };
  mkCi = version:
    let
      nixpkgsVersion = import (./ci + "/${version}.nix");
      pkgsf = import ./nix/nixpkgs.nix { inherit nixpkgsVersion; };
      p = import ./nix/pkgs.nix { inherit pkgsf; };
    in mkTarget version p.validityPackages;
in pkgs.lib.genAttrs versions mkCi // { current = mkTarget "current" pkgs.validityPackages; }
