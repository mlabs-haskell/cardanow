{ pkgs, lib, ... }: {
  networking.hostName = "cardanow";

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

  environment.systemPackages = with pkgs; [ htop bottom ];
}
