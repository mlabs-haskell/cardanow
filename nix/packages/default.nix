{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, ... }:
    {
      packages = {
        cardanow = pkgs.writeShellApplication {
          name = "cardanow";
          runtimeInputs = with pkgs; [
            inputs'.cardano-node.packages.cardano-cli
            inputs'.mithril.packages.mithril-client-cli
            bash
            git
            openssh
            config.packages.cardanow-ts
            toybox
            jq
          ];
          text = ''
            # TODO there is probably a better way to write this
            ln -sfT ${../../nix-store-src/mithril-configurations} mithril-configurations
            ln -sfT ${../../nix-store-src/docker-compose.yaml} docker-compose.yaml
            ln -sfT ${../../nix-store-src/docker-compose-localstack.yaml} docker-compose-localstack.yaml
            ln -sfT ${inputs.cardano-configurations} cardano-configurations

            # Define a function for sourcing scripts
            source_scripts() {
                export NETWORK="$1"
                (
                    # Redirect stdout and stderr to NETWORK.log
                    exec >"$1.log" 2>&1
                    # shellcheck source=/dev/null
                    source "${../../setup_env_vars.sh}"
                    # shellcheck source=/dev/null
                    source "${../../entrypoint.sh}"
                )
            }

            # Loop over different values of NETWORK and run in parallel
            for NETWORK in preview preprod mainnet; do
                source_scripts "$NETWORK" &
            done
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
