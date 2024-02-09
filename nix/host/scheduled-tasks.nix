{ lib, flake, ... }: {
  systemd = {
    timers.cardanow = {
      description = "Run cardanow every 60 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1h";
        OnUnitActiveSec = "1h";
        Unit = "cardanow.service";
      };
    };

    services.cardanow = {
      description = "cardanow";

      serviceConfig = {
        Type = "oneshot";
        User = "root"; # TODO is it needed to be executed by root?
        ExecStart = lib.getExe flake.packages.cardanow;
      };
    };
  };
}
