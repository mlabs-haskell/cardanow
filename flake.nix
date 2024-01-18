{
  description = "cardanow";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
    cardano-node.url = "github:intersectmbo/cardano-node";
    mithril.url = "github:input-output-hk/mithril";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          ./nix/shell.nix
        ];
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];
      };
}
