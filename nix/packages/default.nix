{ dream2nix }: {
  perSystem = { pkgs, inputs', system, ... }: {
    packages.cardanow = pkgs.writeShellApplication {
      name = "cardanow";
      runtimeInputs = [
        inputs'.cardano-node.packages.cardano-cli
        inputs'.mithril.packages.mithril-client-cli
      ];
      text = ''
        ./entrypoint.sh
      '';
    };
    packages.cardanow-ts = dream2nix.lib.evalModules {
      packageSets.nixpkgs = dream2nix.inputs.nixpkgs.legacyPackages.${system};

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
}
