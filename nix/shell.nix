{ inputs, ... }: {
  imports = [
    inputs.devshell.flakeModule
    inputs.pre-commit-hooks-nix.flakeModule
  ];
  perSystem = { config, inputs', pkgs, ... }: {
    pre-commit = {
      settings = {

        hooks = {
          nixpkgs-fmt.enable = true;
          deadnix.enable = true;
          shellcheck.enable = true;
          typos = {
            enable = true;
            excludes = [ ".*\.json" ".*\.age" ];
          };
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
        curl
        docker
        docker-compose
        emmet-ls
        inputs'.agenix.packages.agenix
        inputs'.cardano-node.packages.cardano-cli
        inputs'.mithril.packages.mithril-client-cli
        jq
        nil
        nixos-rebuild
        nodejs_20
        nodePackages.bash-language-server
        nodePackages.vscode-langservers-extracted
        nodePackages.prettier
        # NOTE: this version should match the postgresql version that is used in the docker-compose
        postgresql_14
        sqlite
        typescript
      ];
    };
  };
}
