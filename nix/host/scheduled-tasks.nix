{ lib, flake, config, ... }: {
  systemd = {
    timers.cardanow = {
      description = "Run cardanow every 60 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "0m";
        OnUnitActiveSec = "6h";
        Unit = "cardanow.service";
      };
    };

    services.cardanow = {
      description = "cardanow";

      path = [ config.virtualisation.docker.package ];

      serviceConfig = {
        Type = "oneshot";
        user = "cardanow";
        group = "cardanow";
        ExecStart = lib.getExe flake.packages.cardanow;
        StateDirectory = config.users.users.cardanow.home;
        WorkingDirectory = config.users.users.cardanow.home;
        Restart = "on-failure";
      };
    };
  };
}
