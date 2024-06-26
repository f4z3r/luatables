{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = import nixpkgs {inherit system;};
      luaPackages = {
        lua53 = pkgs.lua53Packages;
        lua52 = pkgs.lua52Packages;
        lua51 = pkgs.lua51Packages;
        luajit = pkgs.luajitPackages;
        default = pkgs.luajitPackages;
      };
      makeLuaShell = shellName: luaPackage:
        pkgs.mkShell {
          packages = [luaPackage.busted luaPackage.luarocks];
          shellHook = ''
            luarocks --local make --deps-only *.rockspec
          '';
        };
    in {
      devShells = builtins.mapAttrs makeLuaShell luaPackages;
    });
}
