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

            # TODO add preprod and mainnet
            export NETWORK=preview
            # shellcheck source=/dev/null
            source ${../../setup_env_vars.sh}
            # shellcheck source=/dev/null
            source ${../../entrypoint.sh}
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
