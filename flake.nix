{
  description = "Watch anime in terminal (only russian sources)";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
    in
    {
      overlays.default = final: _prev: {
        anicli-ru = final.python313Packages.callPackage ./nix/package.nix { src = self; };
      };

      packages = forAllSystems (pkgs: rec {
        anicli-ru = pkgs.python313Packages.callPackage ./nix/package.nix { src = self; };
        default = anicli-ru;
      });

      apps = forAllSystems (pkgs: rec {
        anicli-ru = {
          type = "app";
          program = "${self.packages.${pkgs.system}.anicli-ru}/bin/anicli-ru";
          meta.description = "Watch anime in terminal (only russian sources)";
        };
        default = anicli-ru;
      });

      devShells = forAllSystems (
        pkgs:
        let
          package = self.packages.${pkgs.system}.anicli-ru;
        in
        {
          default = pkgs.mkShell {
            packages = [
              # every runtime dependency, straight from nixpkgs. the package itself
              # is here only for its dist-info: `anicli/__init__.py` reads
              # `version("anicli-ru")` on import, which a bare checkout cannot answer.
              # sources in the cwd still win on sys.path
              (pkgs.python313.withPackages (
                _: package.propagatedBuildInputs ++ [ (pkgs.python313Packages.toPythonModule package) ]
              ))
              pkgs.mpv
              # uv is here to regenerate uv.lock, not to install anything
              pkgs.uv
              pkgs.ruff
              pkgs.mypy
            ];
          };
        }
      );
    };
}
