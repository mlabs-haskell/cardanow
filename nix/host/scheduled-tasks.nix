# TODO make this a NixOS module
# TODO make scheduling smarter, starting points:
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565513548
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565521197
{ lib, flake, config, ... }:
let
  networks = [ "preview" "preprod" "mainnet" ];
  # TODO make this parametric with mode data source. NOTE: we have to keep this despite the 
  # optimization on the clean up to avoid to fill the disk in case the exporting scripts fails 
  # (and then the deletion of the snapshots is not triggere). However, we probably want to make
  # this parametric: exported-snapshots/* folders needs 3 files, all the other should have at most 1
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
  ];
  cardanowPerNetwork = lib.genAttrs networks (network: flake.packages."cardanow-${network}");
  mkCardanowService = network: {
    systemd = {
      timers."cardanow-${network}" = {
        description = "Run cardanow for ${network} every 72 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "72h";
          Unit = "cardanow-${network}.service";
        };
      };
      services."cardanow-${network}" = {
        description = "cardanow-${network}";
        after = [ "network.target" ];
        path = [ config.virtualisation.docker.package ];

        serviceConfig = {
          # TODO better handle env files (now we have only secrets here) using nix
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
        description = "Run local cleanup script every 24 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "24h";
          Unit = "cardanow-cleanup-local-data.service";
        };
      };
      services."cardanow-cleanup-local-data" = {
        after = [ "network.target" ];
        description = "cardanow-cleanup-local-data";

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

