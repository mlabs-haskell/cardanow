{ inputs, config, ... }:
let
  mkHost =
    { nixpkgs ? inputs.nixpkgs
    , system ? "x86_64-linux"
    , modules ? [ ]
    , sshAuthorizedKeys ? [ ]
    ,
    }: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = modules ++ [{
        imports = [
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.age
          ./disko.nix
          ./configuration.nix
          ./scheduled-tasks.nix
          ./docker.nix
        ];
        users.users.root.openssh.authorizedKeys.keys = sshAuthorizedKeys;
        _module.args.flake = config.perSystem system;
      }];
    };
in
{
  flake.nixosConfigurations.cardanow = mkHost {
    sshAuthorizedKeys = import ./ssh-authorized-keys.nix;
  };
  perSystem = { lib, ... }: {
    apps.vm.program =
      let
        cardanow-vm = config.flake.nixosConfigurations.cardanow.extendModules {
          modules = [
            ./vm.nix
          ];
        };
      in
      "${lib.getExe cardanow-vm.config.system.build.vm}";
  };
}
