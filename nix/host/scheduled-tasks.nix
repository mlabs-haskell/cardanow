# TODO make this a NixOS module
# TODO make scheduling smarter, starting points:
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565513548
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565521197
{ lib, flake, config, pkgs, ... }:
let
  networks = [ "preview" "preprod" "mainnet" ];
  # TODO make this parametric with mode data source
  basePaths = [ "kupo-data" "exported-snapshots/kupo" "mithril-snapshots" ];
  mkLocalDataPathFromBase = basePath: lib.concatStringsSep " " (map (network: "${basePath}/${network}") networks);
  localDataPaths = lib.concatStringsSep " " (map mkLocalDataPathFromBase basePaths);
  cardanowPerNetwork = lib.genAttrs networks (network: flake.packages."cardanow-${network}");
  mkCardanowService = network: {
    systemd = {
      timers."cardanow-${network}" = {
        description = "Run cardanow for ${network} every 48 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "48h";
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
          Restart = "on-failure";
        };
      };
    };
  };
  otherServices = {
    systemd = {
      timers."cardanow-cleanup-local-data" = {
        description = "Run local cleanup script every 6 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "6h";
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
          ExecStart = "${lib.getExe flake.packages.cleanup-local-data} 3 ${localDataPaths}";
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
      timers."cardanow-sync-s3-data" = {
        description = "Run s3 sync script every 6 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "6h";
          Unit = "cardanow-sync-s3-data.service";
        };
      };
      services."cardanow-sync-s3-data" = {
        after = [ "network.target" ];
        description = "cardanow-sync-s3-data";

        serviceConfig = {
          EnvironmentFile = config.age.secrets.cardanow-environment.path;
          Type = "simple";
          User = "cardanow";
          Group = "cardanow";
          # TODO exported-snapshot should be a variable / we should move it to somewhere else
          #          ExecStart = "${lib.getExe pkgs.awscli2} s3 sync exported-snapshots s3://cardanow --delete";
          ExecStart = "${lib.getExe pkgs.awscli2} s3 sync s3://cardanow exported-snapshots";
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
    };
  };
  cardanowServices = (lib.lists.map mkCardanowService networks);
in
lib.foldl lib.recursiveUpdate otherServices cardanowServices
