{ lib, flake, config, ... }:
let
  # NOTE: we make the restart interval to reduce the rist of overloading the machine
  restartHours = { preview = 24; preprod = 26; mainnet = 28; };
  networks = [ "preview" "preprod" "mainnet" ];
  # NOTE: we have to keep this despite the 
  # optimization on the clean up to avoid to fill the disk in case the exporting scripts fails 
  # (and then the deletion of the snapshots is not triggere).
  cleanupLocalPaths = lib.concatStringsSep " " [
    "exported-snapshots/preview/kupo"
    "exported-snapshots/preprod/kupo"
    "exported-snapshots/mainnet/kupo"
    "exported-snapshots/preview/cardano-db-sync"
    "exported-snapshots/preprod/cardano-db-sync"
    "exported-snapshots/mainnet/cardano-db-sync"
  ];
  cardanowPerNetwork = lib.genAttrs networks (network: flake.packages."cardanow-${network}");
  mkCardanowService = network:
    let hours = builtins.toString restartHours.${network};
    in {
      systemd = {
        timers."cardanow-${network}" = {
          description = "Run cardanow for ${network} every ${hours} hours";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "0m";
            OnUnitActiveSec = "${hours}h";
            Unit = "cardanow-${network}.service";
          };
        };
        services."cardanow-${network}" = {
          description = "cardanow-${network}";
          after = [ "network.target" ];
          path = [ config.virtualisation.docker.package ];
          environment =
            (import ../variables)
            // (import ../variables/network-based.nix { inherit network; });

          serviceConfig = {
            EnvironmentFile = config.age.secrets.cardanow-environment.path;
            Type = "simple";
            User = "cardanow";
            Group = "cardanow";
            ExecStart = lib.getExe cardanowPerNetwork.${network};
            WorkingDirectory = config.users.users.cardanow.home;
          };
        };
      };
    };
  otherServices = {
    systemd = {
      timers."cardanow-cleanup-local-data" = {
        description = "Run local cleanup script every 12 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "12h";
          Unit = "cardanow-cleanup-local-data.service";
        };
      };
      services."cardanow-cleanup-local-data" = {
        after = [ "network.target" ];
        description = "cardanow-cleanup-local-data";
        environment = import ../variables;
        serviceConfig = {
          EnvironmentFile = config.age.secrets.cardanow-environment.path;
          Type = "simple";
          User = "root";
          Group = "root";
          ExecStart = "${lib.getExe flake.packages.cleanup-local-data} 3 ${cleanupLocalPaths}";
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
      services."cardanow-start-monitoring" = {
        description = "cardanow-start-monitoring";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "forking";
          User = "root";
          Group = "root";
          ExecStart = lib.getExe flake.packages.start-cardanow-monitoring-tmux;
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
    };
  };
  cardanowServices = (lib.lists.map mkCardanowService networks);
in
lib.foldl lib.recursiveUpdate otherServices cardanowServices

