# TODO make this a NixOS module
# TODO make scheduling smarter, starting points:
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565513548
# - https://github.com/mlabs-haskell/cardanow/pull/36#discussion_r1565521197
{ lib, flake, config, ... }:
let
  networks = [ "preview" "preprod" "mainnet" ];
  # TODO make this parametric with mode data source
  basePaths = [ "kupo-data" "exported-snapshots/kupo" "mithril-snapshots" ];
  mkLocalDataPathFromBase = basePath: lib.concatStringsSep " " (map (network: "${basePath}/${network}") networks);
  localDataPaths = lib.concatStringsSep " " (map mkLocalDataPathFromBase basePaths);
  # TODO make this parametric with mode data source
  mkS3DataPath = network: "kupo/${network}/";
  s3DataPaths = lib.concatStringsSep " " (map mkS3DataPath networks);
  bucketName = "cardanow";
  updateFileToServeAfter = command: "${command} && ${lib.getExe flake.packages.get-s3-state}";
  mkCardanowService = network: {
    systemd = {
      timers."cardanow-${network}" = {
        description = "Run cardanow for ${network} every 24 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "48h";
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
          EnvironmentFile = config.age.secrets.cardanow-environment.path;
          Type = "simple";
          User = "cardanow";
          Group = "cardanow";
          ExecStart = updateFileToServeAfter (lib.getExe flake.packages.cardanow);
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
    };
  };
  cleanupServices = {
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
        description = "cardanow-cleanup-local-data";

        serviceConfig = {
          Type = "simple";
          User = "cardanow";
          Group = "cardanow";
          ExecStart = updateFileToServeAfter "${lib.getExe flake.packages.cleanup-local-data} 3 ${localDataPaths}";
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
      timers."cardanow-cleanup-s3" = {
        description = "Run s3 cleanup script every 6 hours";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "0m";
          OnUnitActiveSec = "6h";
          Unit = "cardanow-cleanup-s3-data.service";
        };
      };
      services."cardanow-cleanup-s3-data" = {
        description = "cardanow-cleanup-s3-data";

        serviceConfig = {
          EnvironmentFile = config.age.secrets.cardanow-environment.path;
          Type = "simple";
          User = "cardanow";
          Group = "cardanow";
          ExecStart = updateFileToServeAfter "${lib.getExe flake.packages.cleanup-s3-data} ${bucketName} 3 ${s3DataPaths}";
          WorkingDirectory = config.users.users.cardanow.home;
          Restart = "on-failure";
        };
      };
    };
  };
  cardanowServices = (lib.lists.map mkCardanowService networks);
in
lib.foldl lib.recursiveUpdate cleanupServices cardanowServices
