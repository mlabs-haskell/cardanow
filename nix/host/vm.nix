{ lib, modulesPath, ... }: {
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  networking.hostName = lib.mkForce "cardanow-local";

  virtualisation = {
    graphics = false;
    memorySize = 8192;
    diskSize = 100000;
    forwardPorts = [
      # ssh
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  # WARNING: root access with empty password
  # provides easy debugging via console and ssh
  services.getty.autologinUser = "root";
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  users.users.root.password = "";
}
