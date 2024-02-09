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

  name = lib.mkForce "cardanow-ts";
  version = lib.mkForce "0.0.0.1";

  mkDerivation = {
    src = lib.cleanSource ../../.;
    checkPhase = ''
      npm test
    '';
    doCheck = true;
  };
}
