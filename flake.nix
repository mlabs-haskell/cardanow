{
  description = "cardanow";
  inputs = {
    cardano-node.url = "github:intersectmbo/cardano-node";
    cardano-configurations = {
      url = "github:input-output-hk/cardano-configurations?rev=fa19a63c9a2050940583b10e9f39ed02e3cf306f";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
    disko.url = "github:nix-community/disko";
    dream2nix.url = "github:nix-community/dream2nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mithril-preview.url = "github:input-output-hk/mithril/2418.1-pre";
    # Should work for both preprod & mainnet
    mithril.url = "github:input-output-hk/mithril/2412.0";
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
