{
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users.cardanow = {
    isSystemUser = true;
    home = "/var/lib/cardanow";
    group = "cardanow";
    extraGroups = [ "docker" ];
  };

  users.groups.cardanow = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/cardanow 0775 cardanow cardanow"
  ];
}
