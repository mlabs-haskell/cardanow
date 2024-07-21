{
  description = "cardanow";
  inputs = {
    cardano-node.url = "github:intersectmbo/cardano-node";
    cardano-configurations = {
      url = "github:input-output-hk/cardano-configurations?rev=de80edfd569d82d5191d2c6103834e700787bb2d";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
    disko.url = "github:nix-community/disko";
    dream2nix.url = "github:nix-community/dream2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # Currently the version should match
    mithril-preview.url = "github:input-output-hk/mithril/2428.0";
    # Should work for both preprod & mainnet
    mithril.url = "github:input-output-hk/mithril/2428.0";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    agenix.url = "github:ryantm/agenix";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
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
          ./nix/effects.nix
        ];
        systems = [
          "x86_64-darwin"
          "x86_64-linux"
        ];
      };
}
