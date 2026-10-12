{
  description = "sops-nix-grouped";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: {
      #systems = [ "x86_64-linux" "aarch64-linux" ];

      flake = {
        modules.nixos.default = { pkgs, config, ... }: {
          imports = [
            "${inputs.self}/modules/nixos"
          ];
        };
        nixosModules.default = config.flake.modules.nixos.default;
      };
    });
}
