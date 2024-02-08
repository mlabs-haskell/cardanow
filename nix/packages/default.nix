{ dream2nix }: {
  perSystem = { system, ... }: {
    packages.cardanow = dream2nix.lib.evalModules {
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
