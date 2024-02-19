{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, ... }: {
    packages = {
      cardanow = pkgs.writeShellApplication {
        name = "cardanow";
        runtimeInputs = [
          inputs'.cardano-node.packages.cardano-cli
          inputs'.mithril.packages.mithril-client-cli
          pkgs.bash
          pkgs.git
          pkgs.openssh
        ];
        text =
          # let cardanow = pkgs.fetchFromGitHub { owner = "mlabs-haskell"; repo = "cardanow"; rev = ""; };
          # in ''
          ''
            # TODO add preprod and mainnet
            NETWORK=preview ${../../entrypoint.sh}
          '';
      };
      cardanow-ts = inputs.dream2nix.lib.evalModules {
        packageSets.nixpkgs = inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};
        modules = [
          ./cardanow-ts.nix
        ];
      };
    };
  };
}
