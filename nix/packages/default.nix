{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, ... }: {
    packages = {
      cardanow = pkgs.writeShellApplication {
        name = "cardanow";
        runtimeInputs = [
          inputs'.cardano-node.packages.cardano-cli
          inputs'.mithril.packages.mithril-client-cli
        ];
        text = ''
          # TODO add preprod and mainnet
          NETWORK=preview ./entrypoint.sh
        '';
      };
      cardanow-ts = inputs.dream2nix.lib.evalModules {
        packageSets.nixpkgs = inputs.dream2nix.inputs.nixpkgs.legacyPackages.${system};

        modules = [
          ./cardanow-ts.nix
          {
            paths = {
              projectRoot = ../../.;
              projectRootFile = "flake.nix";
              package = ../../.;
            };
          }
        ];
      };
    };
  };
}
