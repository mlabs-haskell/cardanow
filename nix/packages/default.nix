{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, ... }:
    {
      packages = {
        cleanup-local-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [ bash ];
          text = ''${../../bin/cleanup-local-data.sh} "$@"'';
        };
        cleanup-s3-data = pkgs.writeShellApplication {
          name = "cleanup-local-data";
          runtimeInputs = with pkgs; [ bash awscli2 jq ];
          text = ''${../../bin/cleanup-s3-data.sh} "$@"'';
        };

        cardanow = pkgs.writeShellApplication
          {
            name = "cardanow";
            runtimeInputs = with pkgs; [
              inputs'.cardano-node.packages.cardano-cli
              inputs'.mithril.packages.mithril-client-cli
              git
              openssh
              config.packages.cardanow-ts
              curl
              jq
            ];
            text = ''
              # TODO there is probably a better way to write this
              ln -sfT ${../../nix-store-src/mithril-configurations} mithril-configurations
              ln -sfT ${../../nix-store-src/docker-compose.yaml} docker-compose.yaml
              ln -sfT ${inputs.cardano-configurations} cardano-configurations

              # shellcheck source=/dev/null
              source "${../../setup_env_vars.sh}"
              # shellcheck source=/dev/null
              source "${../../entrypoint.sh}"
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

