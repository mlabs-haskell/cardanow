{ lib
, config
, dream2nix
, ...
}: {
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];
  deps = { nixpkgs, ... }: {
    inherit
      (nixpkgs)
      gnugrep
      stdenv
      ;
  };
  nodejs-package-lock-v3 = {
    packageLockFile = ../../package-lock.json;
  };
  nodejs-granular-v3 = {
    buildScript = ''
      tsc ./main.ts
      mv main.js main.js.tmp
      echo "#!${config.deps.nodejs}/bin/node" > main.js
      cat main.js.tmp >> main.js
      chmod +x ./main.js
      patchShebangs .
    '';
  };

  name = lib.mkForce "main";
  version = lib.mkForce "1.0.0";

  mkDerivation = {
    src = lib.cleanSource ../../.;
    checkPhase = ''
      echo "Check Phase"
    '';
    doCheck = true;
  };
}
