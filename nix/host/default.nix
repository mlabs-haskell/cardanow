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
          ./nginx.nix
        ];
        users.users.root.openssh.authorizedKeys.keys = sshAuthorizedKeys;
        _module.args = {
          flake = config.perSystem system;
          inherit inputs;
        };
      }];
    };
in
{
  flake.nixosConfigurations.cardanow = mkHost {
    sshAuthorizedKeys = with import ../public-keys.nix; (builtins.attrValues users) ++ [ hercules-ci ];
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
