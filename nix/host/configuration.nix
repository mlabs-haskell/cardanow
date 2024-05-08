{ pkgs, lib, ... }: {
  networking.hostName = "cardanow";

  system.stateVersion = "24.05";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 20;
  };
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" ];
  boot.kernelModules = [ "kvm-intel" ];

  networking.useDHCP = lib.mkDefault true;

  services.openssh = {
    settings.PermitRootLogin = "prohibit-password";
    enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # TODO awscli2 is used only by cardanow
  environment.systemPackages = with pkgs; [ htop bottom awscli2 tmux ];

  age.secrets = {
    cardanow-environment = {
      file = ../../secrets/cardanow-environment.age;
      owner = "cardanow";
      group = "cardanow";
      mode = "0440";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };
}
