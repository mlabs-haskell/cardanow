{ lib
, config
, dream2nix
, ...
}:
let
  packageJSON = lib.importJSON (config.paths.projectRoot + "/package.json");
in
{
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
    packageLockFile = config.paths.projectRoot + "/package-lock.json";
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

  name = packageJSON.name;
  version = packageJSON.version;

  mkDerivation = {
    src = lib.cleanSource ../../cardanow-ts;
    checkPhase = ''
      npm test
    '';
    doCheck = true;
  };
  paths = {
    projectRoot = ../../cardanow-ts;
    projectRootFile = "flake.nix";
    package = ../../cardanow-ts;
  };
}
