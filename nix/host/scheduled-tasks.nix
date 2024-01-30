{ lib, flake, ... }: {
  systemd = {
    timers.foo = {
      description = "Run task-foo every 5 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnUnitActiveSec = "5m";
        Unit = "foo.service";
      };
    };

    services.foo = {
      description = "Foo";

      serviceConfig = {
        Type = "oneshot";
        User = "root"; # TODO is it needed to be executed by root?
        ExecStart = lib.getExe flake.packages.cardanow;
      };
    };
  };
}
