{
  description = "cardanow";

  inputs = {
    cardano-node.url = "github:intersectmbo/cardano-node";
    cardano-configurations = {
      url = "github:input-output-hk/cardano-configurations?rev=0d00e479a344c72cf42f8792560ed41c965abb81";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
    disko.url = "github:nix-community/disko";
    dream2nix.url = "github:nix-community/dream2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mithril.url = "github:input-output-hk/mithril";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          ./nix/host
          ./nix/packages
          ./nix/shell.nix
        ];
        systems = [
          "x86_64-darwin"
          "x86_64-linux"
        ];
      };
}
