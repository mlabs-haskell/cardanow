{ inputs, ... }: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks-nix.flakeModule
  ];
  perSystem = { config, inputs', pkgs, ... }: {
    pre-commit = {
      settings = {
        default_stages = [ "commit" "push" ];
        hooks = {
          nixpkgs-fmt.enable = true;
          deadnix.enable = true;
          shellcheck.enable = true;
          typos.enable = true;
        };
        settings = {
          typos.exclude = "*.json";
        };
      };
    };
    devshells.default = {
      devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
      devshell = {
        name = "cardanow";
        motd = ''
          ❄️ Welcome to the {14}{bold}cardanow{reset}'s shell ❄️
        '';
      };
      packages = with pkgs; [
        awscli2
        bash
        docker
        docker-compose
        inputs'.cardano-node.packages.cardano-cli
        inputs'.mithril.packages.mithril-client-cli
        jq
        nil
        nixos-rebuild
        nodejs_20
        wget
      ];
    };
  };
}
