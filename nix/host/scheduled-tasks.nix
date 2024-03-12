{ lib, flake, config, ... }:
let
  networks = [ "preview" "preprod" "mainnet" ];
  systemdComponents = (lib.lists.map mkCardanow networks);
  mkCardanow = network: {
    systemd = {
      timers."cardanow-${network}" = {
        description = "Run cardanow for ${network} every 24 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "24h";
          Unit = "cardanow-${network}.service";
        };
      };

      services."cardanow-${network}" = {
        description = "cardanow-${network}";

        path = [ config.virtualisation.docker.package ];

        environment = {
          NETWORK = network;
        };

        serviceConfig = {

          Type = "simple";
          user = "cardanow";
          group = "cardanow";
          ExecStart = lib.getExe flake.packages.cardanow;
          StateDirectory = config.users.users.cardanow.home;
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
    };
  };
in
lib.foldl lib.recursiveUpdate { } systemdComponents
