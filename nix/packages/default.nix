{ inputs, ... }: {
  perSystem = { pkgs, inputs', system, config, ... }: {
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
          busybox
          jq
        ];
        text = ''
          	  # TODO change name folder mithril configurations
                    ln -sfT ${../../mithril-configurations} mithril-configurations
          	  ln -sfT ${inputs.cardano-configurations} cardano-configurations
                    # TODO add preprod and mainnet
          	  export NETWORK=preview
          	  # shellcheck source=/dev/null
          	  source ${../../setup_env_vars.sh}
                    ${../../entrypoint.sh}
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
