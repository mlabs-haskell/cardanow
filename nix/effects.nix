flakePartsArgs@{ inputs
, withSystem
, ...
}: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
  ];
  herculesCI = { config, ... }:
    withSystem "x86_64-linux" (
      { hci-effects, ... }: {
        onPush.deploy.outputs.effects.deploy-cardanow = hci-effects.runIf (config.repo.branch == "master") (hci-effects.runNixOS {
          inherit (flakePartsArgs.config.flake.nixosConfigurations.cardanow) config;
          secretsMap.ssh = "cardanow-devops-ssh";
          ssh.destination = "root@$cardanow.staging.mlabs.city";
          userSetupScript = ''
            writeSSHKey ssh
            cat >>~/.ssh/known_hosts <<EOF
            ${(import ./public-keys.nix).hosts.cardanow}
            EOF
          '';
        });
      }
    );
}
