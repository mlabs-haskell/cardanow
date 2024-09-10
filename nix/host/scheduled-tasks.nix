{ lib, flake, config, ... }:
let
  # TODO these are temporary and should be tuned:
  # https://github.com/mlabs-haskell/cardanow/issues/91
  restartHours = { preview = 24; preprod = 24; mainnet = 72; };
  networks = [ "preview" "preprod" "mainnet" ];
  # NOTE: we have to keep this despite the 
  # optimization on the clean up to avoid to fill the disk in case the exporting scripts fails 
  # (and then the deletion of the snapshots is not triggere).
  # NOTE: we clean the data in these paths for 2 reasons:
  # - `exported-snapshots/{preview,preprod,mainnter}/{kupo,cardano-db-sync}`: 
  #   we limit these because we are syncing the content of `exported-snapshots` with R2 bucket and
  #   we don't want to control the amount of data we have in the cloud storage
  # - `snapshots/{preview,preprod,mainnter}/{kupo,cardano-db-sync}`: this shouldn't be necessary
  #   because the `snapshot` folder contains temporary artifacts and the exporter services should
  #   clean those up as soon as they are done with the intermediate artifacts. But those services
  #   might fail for unexpected reason and this mechanism is useful to be sure we are not filling up
  #   the local storage. We could keep only 1 intermediate artifact but for the sake of semplicity
  #   we maintain the same number (currently 3) so we keep the clean up script as simple as possible
  cleanupLocalPaths = lib.concatStringsSep " " [
    "snapshots/preview/cardano-node"
    "snapshots/preprod/cardano-node"
    "snapshots/mainnet/cardano-node"
    "snapshots/preview/kupo"
    "snapshots/preprod/kupo"
    "snapshots/mainnet/kupo"
    "exported-snapshots/preview/kupo"
    "exported-snapshots/preprod/kupo"
    "exported-snapshots/mainnet/kupo"
    "snapshots/preview/cardano-db-sync"
    "snapshots/preprod/cardano-db-sync"
    "snapshots/mainnet/cardano-db-sync"
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
          ExecStart = "${lib.getExe flake.packages.cleanup-local-data} 2 ${cleanupLocalPaths}";
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

